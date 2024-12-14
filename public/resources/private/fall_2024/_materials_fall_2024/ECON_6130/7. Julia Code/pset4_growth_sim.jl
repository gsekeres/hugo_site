# Simulate the converged value function over a large number of periods
N = length(simulated_chain)

# Initialize vectors for storing values:
output = zeros(N-1)
consumption = zeros(N-1)
investment = zeros(N-1)
capital = zeros(N)

# Randomize first-period capital:
capital[1] = rand(k_grid)

for i = 1:(N-1)
    # Set income state
    income_state = argmin(abs.(z .- simulated_chain[i]))
    
    # Use policy function to determine next-period capital
    capital[i + 1] = policy_stream[end][argmin(abs.(k_grid .- capital[i])), income_state]

    # Compute output, consumption, and investment
    output[i] = exp(simulated_chain[i]) * capital[i] ^ alpha
    consumption[i] = output[i] + (1 - delta) * capital[i] - capital[i + 1]
    investment[i] = capital[i+1] - (1 - delta) * capital[i]
end

# Compute standard deviations of consumption, investment, and log(output)
std_log_consumption = std(log.(consumption))
std_log_investment = std(log.(investment))
std_log_output = std(log.(output))

# Compute correlations
corr_consumption_investment = cor(log.(consumption), log.(investment))
corr_consumption_output = cor(log.(consumption), log.(output))
corr_investment_output = cor(log.(investment), log.(output))

println("Standard deviation of consumption: $std_log_consumption")
println("Standard deviation of investment: $std_log_investment")
println("Standard deviation of output: $std_log_output")

println("Correlation between consumption and investment: $corr_consumption_investment")
println("Correlation between consumption and output: $corr_consumption_output")
println("Correlation between investment and output: $corr_investment_output")

# Plot consumption, investment, and log(output)
sim_plot = plot()
plot!(sim_plot,log.(consumption), label="Log(Consumption)", title="Output and Choices Over Time", xlabel="Time", ylabel="Value")
plot!(sim_plot,log.(investment), label="Log(Investment)", title="Output and Choices Over Time", xlabel="Time", ylabel="Value")
plot!(sim_plot,log.(output), label="Log(Output)", title="Output and Choices Over Time", xlabel="Time", ylabel="Value")
plot!(sim_plot, legend=:outerright)
display(sim_plot)

savefig(sim_plot,"/Users/gabe/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Julia/pset4_simulated_economy.png")


