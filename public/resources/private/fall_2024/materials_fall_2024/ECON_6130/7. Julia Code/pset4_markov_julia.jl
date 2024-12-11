# Set parameters
persistence = 0.98
lr_var = 0.1
lr_mean = 0.0
e_mean = 0.0
size_space = 7
N = 2000

# Compute the state space and the transition matrix
z,P = tauchen(persistence, lr_var, lr_mean, e_mean, size_space)

# Compute the stationary distribution
stationary_dist = stationary_distribution(P)

# Simulate the Markov chain
simulated_chain = simulate_markov_chain(P, z, N, stationary_dist)

# Compute long-run mean, serial correiation, and volatility
long_run_mean = mean(simulated_chain)
serial_correlation = cor(simulated_chain[1:end-1], simulated_chain[2:end])
volatility = std(simulated_chain)

# Output the results:
println("Long-run Mean: $long_run_mean")
println("Serial Correlation: $serial_correlation")
println("Volatility: $volatility")

p = plot(simulated_chain, title="Markov Chain Simulation, T = 2000", xlabel="Time", ylabel="yt", legend=false)
display(p)
savefig(p,"/Users/gabe/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Julia/pset4_markov.png")
