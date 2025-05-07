using Roots, Plots, StatsBase, LinearAlgebra

# Define parameters
mutable struct Parameters
    R::Float64               # Interest rate (1+r)
    beta::Float64            # Discount factor
    gamma::Float64           # Risk aversion
    P::Matrix{Float64}       # Markov matrix
    y::Vector{Float64}       # Income levels
    assets::Vector{Float64}  # Asset levels
    b::Float64               # Borrowing limit

    """
        Parameters(;
            R::Float64=1.01, 
            beta::Float64=0.98, 
            gamma::Float64=1.5, 
            P::Matrix{Float64}=[0.95 0.05; 0.6 0.4], 
            y::Vector{Float64}=[2.0, 0.0], 
            assets::Vector{Float64}=collect(range(-0.0, 20.0, length=200)), 
            b::Float64=0.0) -> Parameters
    
    Constructor for the Parameters struct.
    """
    function Parameters(;
            R::Float64=1.01, 
            beta::Float64=0.98, 
            gamma::Float64=1.5, 
            P::Matrix{Float64}=[0.95 0.05; 0.6 0.4], 
            y::Vector{Float64}=[2.0, 0.0], 
            assets::Vector{Float64}=collect(range(-0.0, 20.0, length=200)), 
            b::Float64=0.0)
        return new(R, beta, gamma, P, y, assets, b)
    end
end

"""
    linear_interp(x, grid::Vector{Float64}, values::Vector{Float64}) -> Float64

    Linear interpolation helper function.
"""
function linear_interp(x, grid::Vector{Float64}, values::Vector{Float64})
    if x <= grid[1]
        return values[1]
    elseif x >= grid[end]
        return values[end]
    else
        i = searchsortedfirst(grid, x)
        x_low, x_high = grid[i-1], grid[i]
        y_low, y_high = values[i-1], values[i]
        return y_low + (y_high - y_low) * (x - x_low) / (x_high - x_low)
    end
end

"""
    consumption_interp(m::Float64, z::Int, params, c_policy) -> Float64

    Consumption interpolation helper function.
"""
function consumption_interp(a::Float64, z::Int, params, c_policy)
    # Here, params.assets is the grid for cash-on-hand.
    return linear_interp(a, params.assets, c_policy[:, z])
end

"""
    u_prime(c::Float64, params) -> Float64

    Marginal utility function.
"""
function u_prime(c::Float64, params)
    return c^(-params.gamma)
end

"""
    euler_diff(c::Float64, m::Float64, z::Int, c_policy, params) -> Float64

    Euler equation difference function.
"""
function euler_diff(c::Float64, a::Float64, z::Int, c_policy, params)
    # Prevent nonpositive consumption.
    if c <= 0.0
        return 1e10
    end

    # Compute expected marginal utility next period.
    expect = 0.0
    nY = length(params.y)
    for z_next in 1:nY
        a_next = params.R * (a - c) + params.y[z_next]
        c_next = consumption_interp(a_next, z_next, params, c_policy)
        # Ensure c_next is positive.
        if c_next <= 0.0
            c_next = 1e-8
        end
        expect += params.P[z, z_next] * u_prime(c_next, params)
    end

    # The right-hand side: if the constraint binds, we use u'(a).
    rhs = max(params.beta * params.R * expect, u_prime(a, params))
    return u_prime(c, params) - rhs
end

"""
    K_operator(c_policy, params) -> Vector{Float64}

    K operator
"""
function K_operator(c_policy, params)
    nA = length(params.assets)
    nY = length(params.y)
    c_policy_new = similar(c_policy)
    for i in 1:nA
        a = params.assets[i]
        for z in 1:nY
            if a <= 1e-8
                c_policy_new[i, z] = a
            else
                # Solve for c in the interval [1e-8, m] such that euler_diff = 0.
                # We use the bisection (Bisection()) method.
                try
                    sol = find_zero(c -> euler_diff(c, a, z, c_policy, params), (1e-8, a), Bisection(), atol=1e-8)
                    c_policy_new[i, z] = sol
                catch e
                    # If the solver fails (e.g. due to a sign issue), default to an interior guess.
                    c_policy_new[i, z] = 0.5 * a
                end
            end
        end
    end
    return c_policy_new
end

"""
    solve_model_consumption(params; maxiter::Int=1000, tol::Float64=1e-6) -> Vector{Float64}

    Solve the model for consumption.
"""
function solve_model_consumption(params; maxiter::Int=1000, tol::Float64=1e-6, verbose::Bool=true)
    nA = length(params.assets)
    nY = length(params.y)
    
    # Initial guess for consumption: choose an interior guess
    c_policy_old = zeros(nA, nY)
    for i in 1:nA
        a = params.assets[i]
        for z in 1:nY
            c_policy_old[i, z] = a > 1e-8 ? 0.5 * a : a
        end
    end

    diff = 1.0
    iter = 0
    while iter < maxiter && diff > tol
        c_policy_new = K_operator(c_policy_old, params)
        diff = maximum(abs.(c_policy_new .- c_policy_old))
        c_policy_old = c_policy_new
        iter += 1
        if verbose && iter % 25 == 0
            println("Iteration $iter, diff = $diff")
        end
    end

    if verbose && diff > tol
        println("Failed to converge after $maxiter iterations!")
    elseif verbose
        println("Converged in $iter iterations.")
    end

    return c_policy_old
end
"""
    stationary_income(P::Matrix{Float64}) -> Vector{Float64}

    Get stationary distribution for income levels.
"""
function stationary_income(P::Matrix{Float64})
    vals, vecs = eigen(P')
    idx = findall(x -> isapprox(x,1.0; atol=1e-8), vals)
    pi = vecs[:, idx[1]]
    pi = abs.(pi)  # ensure nonnegative
    pi = pi / sum(pi)
    return pi
end

"""
    compute_asset_series(params, c_policy; T)

Simulates a time series of assets of length T (plus the initial asset)
given optimal savings behavior.
"""
function compute_asset_series(params, c_policy; T::Int=500_000)
    nY = length(params.y)
    
    pi = stationary_income(params.P)
    z_seq = Vector{Int}(undef, T)
    z_seq[1] = sample(1:nY, Weights(pi))
    for t in 2:T
         current_state = z_seq[t-1]
         z_seq[t] = sample(1:nY, Weights(params.P[current_state, :]))
    end
    
    # Initialize asset series with a[1] = 0.
    a = zeros(T+1)
    for t in 1:T
         # Get the current income state.
         z = z_seq[t]
         # Compute consumption via linear interpolation on the asset grid.
         c = linear_interp(a[t], params.assets, c_policy[:, z])
         # Update assets: a[t+1] = R*(a[t] - c) + income.
         a[t+1] = params.R * (a[t] - c) + params.y[z]
    end
    return a
end


# Question 1, solve the model when r = 0.01 and b = 0.0
params1 = Parameters(R=1.01, b=0.0, assets=collect(range(-0.0, 20.0, length=1000)))
c_policy1 = solve_model_consumption(params1)
a_policy1 = params1.assets .- c_policy1

# Plot the results
plot(params1.assets, a_policy1[:,1] .+ params1.y[1], label="a'(High Income)")
plot!(params1.assets, a_policy1[:,2] .+ params1.y[2], label="a'(Low Income)")
plot!(params1.assets, params1.assets, linestyle=:dash, label=false)
xlabel!("Current assets")
ylabel!("Optimal next-period assets")
savefig("macro_hw4_code/savings_policy_function1.png")

plot(params1.assets, c_policy1[:,1], label="c'(High Income)")
plot!(params1.assets, c_policy1[:,2], label="c'(Low Income)")
xlabel!("Current assets")
ylabel!("Optimal consumption")
savefig("macro_hw4_code/consumption_policy_function1.png")

# Question 3, solve the model when gamma = 3
params2 = Parameters(gamma=3.0, assets=collect(range(-0.0, 20.0, length=1000)))
c_policy2 = solve_model_consumption(params2)
a_policy2 = params2.assets .- c_policy2

# Plot the results
plot(params2.assets, a_policy2[:,1] .+ params2.y[1], label="a'(High Income)")
plot!(params2.assets, a_policy2[:,2] .+ params2.y[2], label="a'(Low Income)")
plot!(params2.assets, params2.assets, linestyle=:dash, label=false)
xlabel!("Current assets")
ylabel!("Optimal next-period assets")
savefig("macro_hw4_code/savings_policy_function2.png")

plot(params2.assets, c_policy2[:,1], label="c'(High Income)")
plot!(params2.assets, c_policy2[:,2], label="c'(Low Income)")
xlabel!("Current assets")
ylabel!("Optimal consumption")
savefig("macro_hw4_code/consumption_policy_function2.png")

# Question 4, solve the model when b = 4
params3 = Parameters(b=4.0, assets=collect(range(-4.0, 20.0, length=1000)))
c_policy3 = solve_model_consumption(params3)
a_policy3 = params3.assets .- c_policy3

# Plot the results
plot(params3.assets, a_policy3[:,1] .+ params3.y[1], label="a'(High Income)", xlims=(0,20), ylims=(0,Inf))
plot!(params3.assets, a_policy3[:,2] .+ params3.y[2], label="a'(Low Income)", xlims=(0,20), ylims=(0,Inf))
plot!(params3.assets, params3.assets, linestyle=:dash, label=false)
xlabel!("Current assets")
ylabel!("Optimal next-period assets")
savefig("macro_hw4_code/savings_policy_function3.png")

plot(params3.assets, c_policy3[:,1], label="c'(High Income)", xlims=(0,20), ylims=(0,Inf))
plot!(params3.assets, c_policy3[:,2], label="c'(Low Income)", xlims=(0,20), ylims=(0,Inf))
xlabel!("Current assets")
ylabel!("Optimal consumption")
savefig("macro_hw4_code/consumption_policy_function3.png")

# Question 5, get aggregate assets in the stationary distribution
max_interest_rate = (1 / params1.beta) - 1.0
rs = collect(range(0.0, max_interest_rate, length=100))
agg_assets = zeros(length(rs))


for (i, r) in enumerate(rs)
    params_temp = Parameters(R=1+r, b=0.0, assets=collect(range(0.0, 20.0, length=1000)))
    c_policy_temp = solve_model_consumption(params_temp; verbose=false, tol=1e-4)
    a_series = compute_asset_series(params_temp, c_policy_temp, T=250_000)
    agg_assets[i] = mean(a_series)
    println("i = $i, r = $r, agg_assets = $(agg_assets[i])")
end

# Plot aggregate assets vs interest rate.
plot(rs, agg_assets, marker=:o, xlabel="Interest rate (r)", ylabel="Aggregate assets", legend=false)
savefig("macro_hw4_code/aggregate_assets_vs_interest_rate.png")
