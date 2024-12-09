using LinearAlgebra, Symbolics, Plots, Random, Statistics, StatsBase

# Load functions
include("pset5_functions.jl")

@time begin
# Set the parameters
param = [0.99, 2.00, 0.30, 0.03, 0.10, 0.50, 1.00, 0.25, 0.95, 0.01]

# Compute the model equations
fyn, fxn, fypn, fxpn, fn = crra_cd_model(param)

# Compute the gx and hx matrices
gx, hx, exitflag = gx_hx(fyn, fxn, fypn, fxpn)

# Initialize shock
eta = zeros(3,3)
eta[1,1] = param[10]

# Timing of shock
T = 20

# Impulse response functions
IRF_x = zeros(3,T)
IRF_y = zeros(5,T)

for i = 1:T
    IRF_x[:,i] = hx^i * eta * [1 0 0]'
    IRF_y[:,i] = gx * hx^i * eta * [1 0 0]'
end

# Plot the impulse response functions
function three_ticks(y_values)
    min_val = round(minimum(y_values), digits=4)
    max_val = round(maximum(y_values), digits=4)
    mid_val = round((min_val + max_val) / 2, digits=4)
    return [min_val, mid_val, max_val]
end
plot(layout=(4,2), legend=false)
plot!(subplot=1, IRF_x[1,:], title="\$A_{t}\$", yticks=three_ticks(IRF_x[1,:]))
plot!(subplot=2, IRF_x[2,:], title="\$K_{t}\$", yticks=three_ticks(IRF_x[2,:]))
plot!(subplot=3, IRF_x[3,:], title="\$N_{t-1}\$", yticks=three_ticks(IRF_x[3,:]))
plot!(subplot=4, IRF_y[1,:], title="\$Y_{t}\$", yticks=three_ticks(IRF_y[1,:]))
plot!(subplot=5, IRF_y[2,:], title="\$C_{t}\$", yticks=three_ticks(IRF_y[2,:]))
plot!(subplot=6, IRF_y[3,:], title="\$I_{t}\$", yticks=three_ticks(IRF_y[3,:]))
plot!(subplot=7, IRF_y[4,:], title="\$N_{t}\$", yticks=three_ticks(IRF_y[4,:]))
plot!(subplot=8, IRF_y[5,:], title="\$V_{t}\$", yticks=three_ticks(IRF_y[5,:]))


# Save the plot
savefig("/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Julia/pset5_tech_shock.png")

# Simulate with random shocks
Random.seed!(0)
L = 5000
epsilon = vcat(0.0, randn(L))

simX = zeros(3, L+1)
simY = zeros(5, L+1)
for i in 1:L
    simX[:, i+1] = hx * simX[:, i] + eta * [epsilon[i+1], 0, 0]
    simY[:, i+1] = gx * simX[:, i+1]
end

simYt = simY[1, :]
simC = simY[2, :]
simI = simY[3, :]
simN = simY[4, :]
simV = simY[5, :]

# First five realizations of productivity
println("First five realizations of productivity:")
println(simX[1, 2:6])

# Standard Deviations
println("Standard Deviations:")
println("SD Y: ", std(simYt))
println("SD C: ", std(simC))
println("SD I: ", std(simI))
println("SD N: ", std(simN))

# Autocorrelations
acf_Y = autocor(simYt)
acf_C = autocor(simC)
acf_I = autocor(simI)
acf_N = autocor(simN)

# Display results (take second value as first is always 1)
println("Autocorrelations:")
println("Y: ", acf_Y[2])
println("C: ", acf_C[2])
println("I: ", acf_I[2])
println("N: ", acf_N[2])


end

## Optimize the value of sigma to match std ratio to data
@time begin
# Number of sigmas
num = 10000
# Initialize sigmas
sigmas = collect(range(start = 1.5, stop = 100, length = num))

returns = zeros(4,num)
function iterate_sigmas(sigma)
    # Create parameter vector with new sigma
    new_params = [0.99, sigma, 0.30, 0.03, 0.10, 0.50, 1.00, 0.25, 0.95, 0.01]
    
    # Get model matrices with new parameters
    fyn, fxn, fypn, fxpn, fn = crra_cd_model(new_params, verbose=false)
    gx, hx, exitflag = gx_hx(fyn, fxn, fypn, fxpn, stake=1.0, verbose=false)

    if exitflag != 1
        return [1.0, 1.0, 1.0, Float64(exitflag)]
    end

    # Create new simulation matrices for each sigma
    simX_local = zeros(3, L+1)
    simY_local = zeros(5, L+1)

    # Create shock matrix for this iteration
    eta_local = zeros(3,3)
    eta_local[1,1] = new_params[10]  # Use the shock parameter from new_params

    # Simulate with these matrices
    for i in 1:L
        simX_local[:, i+1] = hx * simX_local[:, i] + eta_local * [epsilon[i+1], 0, 0]
        simY_local[:, i+1] = gx * simX_local[:, i+1]
    end

    stdY = std(simY_local[1,:])
    stdN = std(simY_local[4,:])
    ratio_diff = stdN / stdY - 0.8791946  # Target ratio from data
    
    return [stdY, stdN, ratio_diff, Float64(exitflag)]
end

returns = zeros(4,num)
# Iterate over sigmas
for i in 1:num
    returns[:, i] = iterate_sigmas(sigmas[i])
end

valid_indices = findall(x -> x == 1, returns[4,:])  # Find where exitflag == 1

# Filter sigmas and returns
valid_sigmas = sigmas[valid_indices]
valid_returns = returns[:, valid_indices]

# Plot only the valid results
plot(valid_sigmas, valid_returns[3,:], 
     legend=false, 
    yformatter=x->round(x, digits=3))
savefig("/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Julia/pset5_sigma_ratio.png")


# Find optimal sigma among valid results only
min_index = argmin(abs.(valid_returns[3, :]))
optimal_sigma = valid_sigmas[min_index]

println("Optimal sigma: ", optimal_sigma)
println("Ratio: ", valid_returns[3, min_index] + 0.8791946)
println("Std Y: ", valid_returns[1, min_index])
println("Std N: ", valid_returns[2, min_index])

# Create a vector to indicate validity of each sigma
validity = zeros(Int, num)
validity[valid_indices] .= 1

# Plot the validity of each sigma
plot(sigmas, validity, 
     legend=false, 
     yformatter=x->round(x, digits=0),
     xlabel="Sigma", ylabel="Validity (1=valid, 0=invalid)")
savefig("/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Julia/pset5_sigma_validity.png")

# Get full optimal std and autocorrelations
opt_params = [0.99, optimal_sigma, 0.30, 0.03, 0.10, 0.50, 1.00, 0.25, 0.95, 0.01]

opt_fyn, opt_fxn, opt_fypn, opt_fxpn, opt_fn = crra_cd_model(opt_params, verbose=false)
opt_gx, opt_hx, opt_exitflag = gx_hx(opt_fyn, opt_fxn, opt_fypn, opt_fxpn, stake=1.0, verbose=false)

simX_opt = zeros(3, L+1)
simY_opt = zeros(5, L+1)

eta_opt = zeros(3,3)
eta_opt[1,1] = opt_params[10] 
for i in 1:L
    simX_opt[:, i+1] = opt_hx * simX_opt[:, i] + eta_opt * [epsilon[i+1], 0, 0]
    simY_opt[:, i+1] = opt_gx * simX_opt[:, i+1]
end

simYt_opt = simY_opt[1, :]
simC_opt = simY_opt[2, :]
simI_opt = simY_opt[3, :]
simN_opt = simY_opt[4, :]

# Standard Deviations
println("Standard Deviations:")
println("SD Y: ", std(simYt_opt))
println("SD C: ", std(simC_opt))
println("SD I: ", std(simI_opt))
println("SD N: ", std(simN_opt))

# Autocorrelations
acf_Y_opt = autocor(simYt_opt)
acf_C_opt = autocor(simC_opt)
acf_I_opt = autocor(simI_opt)
acf_N_opt = autocor(simN_opt)

# Display results (take second value as first is always 1)
println("Autocorrelations:")
println("Y: ", acf_Y_opt[2])
println("C: ", acf_C_opt[2])
println("I: ", acf_I_opt[2])
println("N: ", acf_N_opt[2])


end



