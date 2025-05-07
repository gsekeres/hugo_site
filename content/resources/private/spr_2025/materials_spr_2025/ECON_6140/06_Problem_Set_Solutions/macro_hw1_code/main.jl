# Parameters
N = 600
alpha = 0.33
beta = 0.98
delta = 0.10    
sigma = 0.95

# Set utility and production functions
function u(c)
    return c^(1 - sigma) / (1 - sigma)
end

function u_prime(c)
    return c^(-sigma)
end

function u_prime_inv(c)
    return c^(-1 / sigma)
end

# Production function and its derivative
function f(k)
    return k^alpha
end

function f_prime(k)
    return alpha * k^(alpha - 1)
end

# Function to compute next capital and consumption
function next_k_c(k, c)
    k_next = f(k) + (1 - delta) * k - c
    c_next = u_prime_inv(u_prime(c) / (beta * (f_prime(k_next) + (1 - delta))))
    return k_next, c_next
end

# Shooting algorithm
function shooting(c0, k0, T=N)
    if c0 > f(k0) + (1 - delta) * k0
        println("Initial consumption is not feasible")
        return nothing, nothing
    end

    c_vec = zeros(T + 1)
    k_vec = zeros(T + 2)

    c_vec[1] = c0
    k_vec[1] = k0

    for t in 1:T
        k_vec[t + 1], c_vec[t + 1] = next_k_c(k_vec[t], c_vec[t])
        #println("t=$t, k=$(k_vec[t + 1]), c=$(c_vec[t + 1])")
        if isnan(k_vec[t + 1]) || isinf(k_vec[t + 1])
            println("Numerical instability detected at t=$t.")
            return nothing, nothing
        end
    end

    k_vec[T + 2] = f(k_vec[T + 1]) + (1 - delta) * k_vec[T + 1] - c_vec[T + 1]

    return c_vec, k_vec
end

# Steady state
k_star = ((1/beta - 1 + delta) / alpha)^(1/(alpha-1))

# Initial guess for capital
k0 = 0.85 * k_star

# Global optima for consumption
c_min = 0
c_max = f(k_star)
c_curr = (c_min + c_max) / 2

function find_optimal_c0(c_min, c_max, k0, k_star)
    dist = 1
    iter = 0
    while dist > 1e-6 && iter < 1000
        global c_curr = (c_min + c_max) / 2
        c_path, k_path = shooting(c_curr, k0)
        if k_path === nothing
            continue
        end
        if k_path[end] < 0
            c_max = c_curr
        else
            c_min = c_curr
        end
        dist = abs(k_path[end])
        println("Trying c0 = $c_curr, dist = $dist, k_path[N] = $(k_path[N])")
        iter += 1
    end
    return c_curr, iter
end

c0, iter = find_optimal_c0(c_min, c_max, k0, k_star)

println("Optimal c0: $c0")
println("Iterations: $iter")

c_path, k_path = shooting(c0, k0)
println(c_path[end])
println(k_path[end])