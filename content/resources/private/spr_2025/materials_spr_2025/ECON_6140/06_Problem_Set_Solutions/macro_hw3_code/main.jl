using Plots, LaTeXStrings, PyPlot

@time begin

# Make the plots look pretty
pyplot()
PyPlot.rc("text", usetex=true)
PyPlot.rc("font", family="serif")
PyPlot.matplotlib.rcParams["mathtext.fontset"] = "cm"

# Set parameters
beta    = 0.98      
N       = 1000     
x_min   = 0.0    
x_max   = 100.0   
x_grid  = range(x_min, x_max, length = N)

# VFI settings
max_iter    = 500
tol         = 1e-4

# Settings for the consumption grid (per state)
M           = 200    
eps         = 1e-6  

# Utility function
u(c) = log(c)

# Linear interpolation
function interp_value(x, x_grid, V)
    # If x is at or below the minimum grid point, return V[1]
    if x <= first(x_grid)
        return V[1]
    # If x is above the maximum grid point, return the last value
    elseif x >= last(x_grid)
        return V[end]
    else
        # Find the index i such that x_grid[i] <= x < x_grid[i+1]
        i = searchsortedlast(x_grid, x)
        # Linear interpolation between x_grid[i] and x_grid[i+1]
        x_low, x_high = x_grid[i], x_grid[i+1]
        V_low, V_high = V[i], V[i+1]
        return V_low + (V_high - V_low) * (x - x_low) / (x_high - x_low)
    end
end

# Bellman operator
function bellman_operator(V, x_grid, beta; M = 200, eps = 1e-6, delta = 0.0)
    V_new = similar(V)
    for (i, x) in enumerate(x_grid)
        # At x = 0 (or very near 0), define v(0)=0 directly.
        if x < eps
            V_new[i] = 0.0
        else
            # Create a grid for consumption c from a tiny positive number to x
            c_grid = range(eps, stop = x, length = M)
            # Compute the candidate value for each consumption c
            # (Here, next cake is x - c, and we use interpolation for v(x-c))
            candidate_vals = [ u(c) + beta * (1 - delta) * interp_value(x - c, x_grid, V) for c in c_grid ]
            # The updated value function at state x is the maximum over candidates
            V_new[i] = maximum(candidate_vals)
        end
    end
    return V_new
end

# Value Function Iteration
function vfi(x_grid, beta; tol = 1e-4, max_iter = 500, M = 200, eps = 1e-6, delta = 0.0)
    V = zeros(length(x_grid))          # initial guess: v(x)=0 everywhere
    err = tol + 1.0
    iter = 0
    while err > tol && iter < max_iter
        V_new = bellman_operator(V, x_grid, beta; M = M, eps = eps, delta = delta)
        err = maximum(abs.(V_new .- V))
        V = V_new
        iter += 1
    end
    println("Converged in $iter iterations with error = $err")
    return V
end

# Initial problem
V_init = vfi(x_grid, beta; tol = tol, max_iter = max_iter, M = M, eps = eps, delta = 0.0)

# Plot the computed value function.
plot(x_grid, V_init, label = L"Value Function ($\delta = 0$)", xlabel = L"Initial Endowment $x_0$", ylabel = L"Value $v(x_0)$", lw = 2, legend = :topleft)
savefig("macro_hw3_code/value_function.png")

        
# Probability 0.5 of losing endowment
V_delta = vfi(x_grid, beta; tol = tol, max_iter = max_iter, M = M, eps = eps, delta = 0.5)

# Plot the computed value function.
plot!(x_grid, V_delta, label = L"Value Function ($\delta = 0.5$)", xlabel = L"Initial Endowment $x_0$", ylabel = L"Value $v(x_0)$", lw = 2, legend = :topleft)
savefig("macro_hw3_code/value_function_delta.png")


# Define subsistence level
c_bar = x_grid ./ 100

# Bellman operator with subsistence utility
function bellman_operator_subsistence(V, x_grid, beta; M = 200, eps = 1e-6, delta = 0.0, c_bar = x_grid ./ 100)
    V_new = similar(V)
    for (i, x) in enumerate(x_grid)
        # At x = 0 (or very near 0), define v(0)=0 directly.
        if x < eps
            V_new[i] = 0.0
        else
            # Create a grid for consumption c from a tiny positive number to x
            c_grid = range(c_bar[i], stop = x, length = M)
            # Compute the candidate value for each consumption c
            # (Here, next cake is x - c, and we use interpolation for v(x-c))
            candidate_vals = [ u(c - c_bar[i]) + beta * (1 - delta) * interp_value(x - c, x_grid, V) for c in c_grid ]
            # The updated value function at state x is the maximum over candidates
            V_new[i] = maximum(candidate_vals)
        end
    end
    return V_new
end

# Value Function Iteration with subsistence utility
function vfi_subsistence(x_grid, beta; tol = 1e-4, max_iter = 500, M = 200, eps = 1e-6, delta = 0.0, c_bar = x_grid ./ 100)
    V = zeros(length(x_grid))          # initial guess: v(x)=0 everywhere
    err = tol + 1.0
    iter = 0
    while err > tol && iter < max_iter
        V_new = bellman_operator_subsistence(V, x_grid, beta; M = M, eps = eps, delta = delta, c_bar = c_bar)
        err = maximum(abs.(V_new .- V))
        V = V_new
        iter += 1
    end
    println("Converged in $iter iterations with error = $err")
    return V
end

# Perform value function iteration
V_base = vfi(x_grid, beta; tol = tol, max_iter = max_iter, M = M, eps = eps, delta = 0.0)
V_subs = vfi_subsistence(x_grid, beta; tol = tol, max_iter = max_iter, M = M, eps = eps, delta = 0.0, c_bar = c_bar)

# Plot the computed value function.
plot(x_grid, V_base, label = L"Value Function ($\bar{c}=0$)", xlabel = L"Initial Endowment $x_0$", ylabel = L"Value $v(x_0)$", lw = 2, legend = :topleft)
plot!(x_grid, V_subs, label = L"Value Function ($\bar{c}=0.01x_0$)", xlabel = L"Initial Endowment $x_0$", ylabel = L"Value $v(x_0)$", lw = 2, legend = :topleft)
savefig("macro_hw3_code/value_function_subsistence.png")

end







