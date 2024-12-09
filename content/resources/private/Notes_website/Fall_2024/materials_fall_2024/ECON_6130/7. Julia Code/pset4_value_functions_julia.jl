"""
    log_markov_utility(k_t, y_t, k_next, alpha, beta, v_next, P)

Computes utility for a given level of capital, choice of capital, and value function.

Returns calculated utility.
"""
function log_markov_utility(k_t::Float64, y_t::Float64, k_next::Float64, alpha::Float64, beta::Float64,
     v_next::Vector{Float64}, P::Vector{Float64})
    # Check feasibility of consumption
    consumption = exp(y_t) * k_t^alpha + (1 - delta) * k_t - k_next
    
    if consumption <= 0 || k_next <= 0
        return -Inf  # Large penalty for infeasible consumption
    else
        return log(consumption) + beta * sum(P .* v_next)
    end
end

"""
    function value_function_iteration(grid_size, size_space, k_grid, z, P, alpha, beta, tol, utility_form)

Takes in parameters, a capital grid, and a functional form for utility, and performs the value function iteration.

Returns the stream of value functions, and the indices of the optimal policy choices.
"""
function value_function_iteration(grid_size::Int, size_space::Int, k_grid::Vector{Float64}, z::Vector{Float64}, 
    P::Matrix{Float64}, alpha::Float64, beta::Float64, tol::Float64, utility_form::Function)
   # Initialize value function (2 layers for old and new iteration)
   value = zeros(2, grid_size, size_space)
   sup = 1.0  # To track convergence

   # Initialize streams for value and policy functions
   value_stream = []
   policy_indices_stream = []  # To store the policy indices

   # Objective value for each (i, k, j)
   value_iter = zeros(grid_size, size_space, grid_size)

   while sup >= tol
       # Update the previous value function with the current one
       value[1, :, :] .= value[2, :, :]

       # Compute the new value function and policy extraction simultaneously
       policy_indices = zeros(Int, grid_size, size_space)  # To store policy (index of k_next)

       for k in 1:size_space
           for i in 1:grid_size
               for j in 1:grid_size
                   # Compute utility and future value
                   value_iter[i, k, j] = utility_form(k_grid[i], z[k], k_grid[j], alpha, beta, value[1, j, :], P[k, :])
               end
               # Maximize over next-period capital (k_grid)
               max_value, max_index = findmax(value_iter[i, k, :])
               value[2, i, k] = max_value  # Store the maximum value
               policy_indices[i, k] = max_index  # Store the index of the maximizing capital choice
           end
       end

       # Push the current value function and policy indices into their respective streams
       push!(value_stream, copy(value[2, :, :]))
       push!(policy_indices_stream, copy(policy_indices))

       # Update the sup norm to track convergence
       sup = maximum(abs.(value[2, :, :] - value[1, :, :]))
   end

   return value_stream, policy_indices_stream
end

"""
    extract_policy(grid_size, size_space, value_stream, k_grid)

Computes the policy that optimized every value function iteration.

Returns the stream of policy functions.
"""
function extract_policy(grid_size::Int, size_space::Int, policy_indices_stream::Array{Any,1}, k_grid::Vector{Float64})
    # Store the policy functions (chosen capital values)
    policy_stream = []
    
    # Iterate over each iteration to extract policy functions based on indices
    for iter in 1:length(policy_indices_stream)
        policy = zeros(grid_size, size_space)
        
        for i in 1:grid_size
            for j in 1:size_space
                # Use the policy index to get the chosen capital from k_grid
                policy[i, j] = k_grid[policy_indices_stream[iter][i, j]]
            end
        end
        
        # Append the current policy function to the stream
        push!(policy_stream, copy(policy))
    end
    
    return policy_stream
end


"""
    solve_value_function(persistence, lr_var, lr_mean, e_mean, size_space, grid_size, grid_min, grid_max, alpha, beta, tol, utility_form)

Take in parameters for the Tauchen Markov process and the capital grid, as well as the problem parameters and a utility functional form.

Return a set of value function and policy function iterations, as well as the capital grid.
"""
function solve_value_function(persistence::Float64, lr_var::Float64, lr_mean::Float64, e_mean::Float64, 
    size_space::Int, grid_size::Int, grid_min::Float64, grid_max::Float64, alpha::Float64, beta::Float64, 
    tol::Float64, utility_form::Function)
    # Get sample space and transition matrix
    z, P = tauchen(persistence, lr_var, lr_mean, e_mean, size_space)
    # Get capital grid
    k_grid = collect(LinRange(grid_min, grid_max, grid_size))
    # Perform value function iteration
    value_stream, policy_indices_stream = value_function_iteration(grid_size, size_space, k_grid, z, P, alpha, beta, tol, utility_form)
    # Extract policy function
    policy_stream = extract_policy(grid_size, size_space, policy_indices_stream, k_grid)

    return value_stream, policy_stream, k_grid
end