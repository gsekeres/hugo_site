# Problem Parameters:
N = 100
alpha = 0.35
beta = 0.95
delta = 0.1
tol = 1e-6

# Uncertainty Parameters:
persistence = 0.98
lr_var = 0.1
lr_mean = 0.0
e_mean = 0.0
size_space = 7

# Capital Grid Parameters:
k_ss = 3.585
grid_size = 100
grid_min = 0.25 * k_ss
grid_max = 2 * k_ss

# Utility function:
utility_form = log_markov_utility

value_stream, policy_stream, k_grid = solve_value_function(persistence, lr_var, lr_mean, e_mean, size_space, grid_size, grid_min, grid_max, alpha, beta, tol, utility_form)




p_final_value = plot()
for state in 1:size_space
    plot!(p_final_value, k_grid, value_stream[end][:, state], label = "State $state", 
          title = "Final Value Function for All States", xlabel = "State Capital (k)", ylabel = "Value (v)")
end

plot!(p_final_value, legend=:outerright)
display(p_final_value)
savefig(p_final_value, "/Users/gabe/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Julia/pset4_final_value_function.png")


p_final_policy = plot()
for state in 1:size_space
    plot!(p_final_policy, k_grid, policy_stream[end][:, state], label = "State $state", 
          title = "Final Policy Function for All States", xlabel = "State Capital (k)", ylabel = "Chosen Capital (k')")
end

plot!(p_final_policy, legend=:outerright)
display(p_final_policy)
savefig(p_final_policy, "/Users/gabe/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Julia/pset4_final_policy_function.png")


# Number of iterations:
iters = length(value_stream)
println("Number of Iterations: $iters")



