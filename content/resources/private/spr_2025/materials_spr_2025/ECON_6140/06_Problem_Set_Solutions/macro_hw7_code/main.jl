using Random, Distributions, Plots
include("functions.jl")
# Make the plots look pretty
pyplot()
PyPlot.rc("text", usetex=true)
PyPlot.rc("font", family="serif")
PyPlot.matplotlib.rcParams["mathtext.fontset"] = "cm"
# Initialize parameters
p = Parameters()

# 1: Solve using method of undetermined coefficients
psis = undet_coef(p)
println("psi_pi_a: $(psis[1])")
println("psi_y_a: $(psis[2])")
println("psi_pi_z: $(psis[3])")
println("psi_y_z: $(psis[4])")

# 2: Simulate the model
T = 100
yInit, piInit, wInit, iInit, aInit, zInit, y_tildeInit, y_nInit = simulate(p, T)

plt2 = plot(background=:transparent, legend=:outerbottom, legendcolumns=4, xlabel="Time", ylabel="Value", title="Simulated Model", linewidth=2, linealpha=0.7, size=(825,250))
plot!(plt2, yInit, label="Output")
plot!(plt2, piInit, label="Inflation")
plot!(plt2, wInit, label="Real Wage")
plot!(plt2, iInit, label="Nominal Interest Rate")

savefig(plt2, "macro_hw7_code/2_simulated_model.png")

# 3: Follow a single firm j through the simulation
price_data = zeros(T)
price_data[1] = 100
for t in 2:T
    price_data[t] = price_data[t-1] * exp(piInit[t])
end

price_firm = zeros(T)
price_firm[1] = 100
for t in 2:T
    if rand() < p.theta # Firm cannot change price
        price_firm[t] = price_firm[t-1]
    else # Firm can change price
        price_firm[t] = price_data[t]
    end
end
output_firm = (yInit .+ (-p.epsilon) * (price_firm - price_data)) ./ price_firm
mc_aggregate = ((p.sigma + (p.varphi + p.alpha) / (1 - p.alpha))) .* yInit .- log(1 - p.alpha) .- (1 + p.varphi) / (1 - p.alpha) .* aInit
mc_firm = (mc_aggregate .- (p.alpha + p.epsilon) / (1 - p.alpha) * (price_firm - price_data)) ./ price_firm


plt3a = plot(background=:transparent, legend=false, xlabel="Time", ylabel="Price", title="Firm Price Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt3a, price_firm, label="Firm Price")

savefig(plt3a, "macro_hw7_code/3a_firm_price_data.png")

plt3b = plot(background=:transparent, legend=false, xlabel="Time", ylabel="Price", title="Price Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt3b, price_firm, label="Firm Price")
plot!(plt3b, price_data, label="Aggregate Price")

savefig(plt3b, "macro_hw7_code/3b_price_data.png")

plt3c = plot(background=:transparent, legend=:outerbottom, legendcolumns=2, xlabel="Time", ylabel="Output", title="Output Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt3c, output_firm, label="Firm Output")
plot!(plt3c, yInit, label="Aggregate Output")

savefig(plt3c, "macro_hw7_code/3c_output_data.png")

plt3d = plot(background=:transparent, legend=:outerbottom, legendcolumns=2, xlabel="Time", ylabel="Output", title="Marginal Cost Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt3d, mc_firm, label="Firm Marginal Cost")
plot!(plt3d, mc_aggregate, label="Aggregate Marginal Cost")

savefig(plt3d, "macro_hw7_code/3d_marginal_cost_data.png")


# 4a: Simulate the model with epsilon = 10
p_epsilon = Parameters(epsilon=10.0)
psis_epsilon = undet_coef(p_epsilon)

y_epsilon, pi_epsilon, w_epsilon, i_epsilon, a_epsilon, z_epsilon = simulate(p_epsilon, T)
plt4a2 = plot(background=:transparent, legend=:outerbottom, legendcolumns=4, xlabel="Time", ylabel="Value", title="Simulated Model", linewidth=2, linealpha=0.7, size=(825,250))
plot!(plt4a2, y_epsilon, label="Output")
plot!(plt4a2, pi_epsilon, label="Inflation")
plot!(plt4a2, w_epsilon, label="Real Wage")
plot!(plt4a2, i_epsilon, label="Nominal Interest Rate")

savefig(plt4a2, "macro_hw7_code/4a2_simulated_model.png")

price_data_epsilon = zeros(T)
price_data_epsilon[1] = 100
for t in 2:T
    price_data_epsilon[t] = price_data_epsilon[t-1] * exp(pi_epsilon[t])
end

price_firm_epsilon = zeros(T)
price_firm_epsilon[1] = 100
for t in 2:T
    if rand() < p_epsilon.theta # Firm cannot change price
        price_firm_epsilon[t] = price_firm_epsilon[t-1]
    else # Firm can change price
        price_firm_epsilon[t] = price_data_epsilon[t]
    end
end
output_firm_epsilon = (y_epsilon .+ (-p_epsilon.epsilon) * (price_firm_epsilon - price_data_epsilon)) ./ price_firm_epsilon
mc_aggregate_epsilon = ((p_epsilon.sigma + (p_epsilon.varphi + p_epsilon.alpha) / (1 - p_epsilon.alpha))) .* y_epsilon .- log(1 - p_epsilon.alpha) .- (1 + p_epsilon.varphi) / (1 - p_epsilon.alpha) .* a_epsilon
mc_firm_epsilon = (mc_aggregate_epsilon .- (p_epsilon.alpha + p_epsilon.epsilon) / (1 - p_epsilon.alpha) * (price_firm_epsilon - price_data_epsilon)) ./ price_firm_epsilon


plt4a3a = plot(background=:transparent, legend=false, xlabel="Time", ylabel="Price", title="Firm Price Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4a3a, price_firm_epsilon, label="Firm Price")

savefig(plt4a3a, "macro_hw7_code/4a3a_firm_price_data.png")

plt4a3b = plot(background=:transparent, legend=false, xlabel="Time", ylabel="Price", title="Price Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4a3b, price_firm_epsilon, label="Firm Price")
plot!(plt4a3b, price_data_epsilon, label="Aggregate Price")

savefig(plt4a3b, "macro_hw7_code/4a3b_price_data.png")

plt4a3c = plot(background=:transparent, legend=:outerbottom, legendcolumns=2, xlabel="Time", ylabel="Output", title="Output Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4a3c, output_firm_epsilon, label="Firm Output")
plot!(plt4a3c, y_epsilon, label="Aggregate Output")

savefig(plt4a3c, "macro_hw7_code/4a3c_output_data.png")

plt4a3d = plot(background=:transparent, legend=:outerbottom, legendcolumns=2, xlabel="Time", ylabel="Output", title="Marginal Cost Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4a3d, mc_firm_epsilon, label="Firm Marginal Cost")
plot!(plt4a3d, mc_aggregate_epsilon, label="Aggregate Marginal Cost")

savefig(plt4a3d, "macro_hw7_code/4a3d_marginal_cost_data.png")

println("With epsilon = 10:")
println("Variance of inflation: $(var(pi_epsilon)), old variance: $(var(piInit))")
println("Variance of output: $(var(y_epsilon)), old variance: $(var(yInit))")
println("Variance of marginal cost: $(var(mc_firm_epsilon)), old variance: $(var(mc_firm))")

# 4b: Simulate the model with alpha = 0
p_alpha = Parameters(alpha=0.0)
psis_alpha = undet_coef(p_alpha)

y_alpha, pi_alpha, w_alpha, i_alpha, a_alpha, z_alpha = simulate(p_alpha, T)
plt4b2 = plot(background=:transparent, legend=:outerbottom, legendcolumns=4, xlabel="Time", ylabel="Value", title="Simulated Model", linewidth=2, linealpha=0.7, size=(825,250))
plot!(plt4b2, y_alpha, label="Output")
plot!(plt4b2, pi_alpha, label="Inflation")
plot!(plt4b2, w_alpha, label="Real Wage")
plot!(plt4b2, i_alpha, label="Nominal Interest Rate")

savefig(plt4b2, "macro_hw7_code/4b2_simulated_model.png")

price_data_alpha = zeros(T)
price_data_alpha[1] = 100
for t in 2:T
    price_data_alpha[t] = price_data_alpha[t-1] * exp(pi_alpha[t])
end

price_firm_alpha = zeros(T)
price_firm_alpha[1] = 100
for t in 2:T
    if rand() < p_alpha.theta # Firm cannot change price
        price_firm_alpha[t] = price_firm_alpha[t-1]
    else # Firm can change price
        price_firm_alpha[t] = price_data_alpha[t]
    end
end
output_firm_alpha = (y_alpha .+ (-p_alpha.epsilon) * (price_firm_alpha - price_data_alpha)) ./ price_firm_alpha
mc_aggregate_alpha = ((p_alpha.sigma + (p_alpha.varphi + p_alpha.alpha) / (1 - p_alpha.alpha))) .* y_alpha .- log(1 - p_alpha.alpha) .- (1 + p_alpha.varphi) / (1 - p_alpha.alpha) .* a_alpha
mc_firm_alpha = (mc_aggregate_alpha .- (p_alpha.alpha + p_alpha.epsilon) / (1 - p_alpha.alpha) * (price_firm_alpha - price_data_alpha)) ./ price_firm_alpha


plt4b3a = plot(background=:transparent, legend=false, xlabel="Time", ylabel="Price", title="Firm Price Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4b3a, price_firm_alpha, label="Firm Price")

savefig(plt4b3a, "macro_hw7_code/4b3a_firm_price_data.png")

plt4b3b = plot(background=:transparent, legend=false, xlabel="Time", ylabel="Price", title="Price Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4b3b, price_firm_alpha, label="Firm Price")
plot!(plt4b3b, price_data_alpha, label="Aggregate Price")

savefig(plt4b3b, "macro_hw7_code/4b3b_price_data.png")

plt4b3c = plot(background=:transparent, legend=:outerbottom, legendcolumns=2, xlabel="Time", ylabel="Output", title="Output Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4b3c, output_firm_alpha, label="Firm Output")
plot!(plt4b3c, y_alpha, label="Aggregate Output")

savefig(plt4b3c, "macro_hw7_code/4b3c_output_data.png")

plt4b3d = plot(background=:transparent, legend=:outerbottom, legendcolumns=2, xlabel="Time", ylabel="Output", title="Marginal Cost Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4b3d, mc_firm_alpha, label="Firm Marginal Cost")
plot!(plt4b3d, mc_aggregate_alpha, label="Aggregate Marginal Cost")

savefig(plt4b3d, "macro_hw7_code/4b3d_marginal_cost_data.png")

println("With alpha = 0:")
println("Variance of inflation: $(var(pi_alpha)), old variance: $(var(piInit))")
println("Variance of output: $(var(y_alpha)), old variance: $(var(yInit))")
println("Variance of marginal cost: $(var(mc_firm_alpha)), old variance: $(var(mc_firm))")

# 4c: Simulate the model with phipi = 10 and phiy = 0
p_phipi = Parameters(phipi=10.0, phiy=0.0)
psis_phipi = undet_coef(p_phipi)

y_phipi, pi_phipi, w_phipi, i_phipi, a_phipi, z_phipi = simulate(p_phipi, T)
plt4c2 = plot(background=:transparent, legend=:outerbottom, legendcolumns=4, xlabel="Time", ylabel="Value", title="Simulated Model", linewidth=2, linealpha=0.7, size=(825,250))
plot!(plt4c2, y_phipi, label="Output")
plot!(plt4c2, pi_phipi, label="Inflation")
plot!(plt4c2, w_phipi, label="Real Wage")
plot!(plt4c2, i_phipi, label="Nominal Interest Rate")

savefig(plt4c2, "macro_hw7_code/4c2_simulated_model.png")

price_data_phipi = zeros(T)
price_data_phipi[1] = 100
for t in 2:T
    price_data_phipi[t] = price_data_phipi[t-1] * exp(pi_phipi[t])
end

price_firm_phipi = zeros(T)
price_firm_phipi[1] = 100
for t in 2:T
    if rand() < p_phipi.theta # Firm cannot change price
        price_firm_phipi[t] = price_firm_phipi[t-1]
    else # Firm can change price
        price_firm_phipi[t] = price_data_phipi[t]
    end
end
output_firm_phipi = (y_phipi .+ (-p_phipi.epsilon) * (price_firm_phipi - price_data_phipi)) ./ price_firm_phipi
mc_aggregate_phipi = ((p_phipi.sigma + (p_phipi.varphi + p_phipi.alpha) / (1 - p_phipi.alpha))) .* y_phipi .- log(1 - p_phipi.alpha) .- (1 + p_phipi.varphi) / (1 - p_phipi.alpha) .* a_phipi
mc_firm_phipi = (mc_aggregate_phipi .- (p_phipi.alpha + p_phipi.epsilon) / (1 - p_phipi.alpha) * (price_firm_phipi - price_data_phipi)) ./ price_firm_phipi


plt4c3a = plot(background=:transparent, legend=false, xlabel="Time", ylabel="Price", title="Firm Price Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4c3a, price_firm_phipi, label="Firm Price")

savefig(plt4c3a, "macro_hw7_code/4c3a_firm_price_data.png")

plt4c3b = plot(background=:transparent, legend=false, xlabel="Time", ylabel="Price", title="Price Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4c3b, price_firm_phipi, label="Firm Price")
plot!(plt4c3b, price_data_phipi, label="Aggregate Price")

savefig(plt4c3b, "macro_hw7_code/4c3b_price_data.png")

plt4c3c = plot(background=:transparent, legend=:outerbottom, legendcolumns=2, xlabel="Time", ylabel="Output", title="Output Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4c3c, output_firm_phipi, label="Firm Output")
plot!(plt4c3c, y_phipi, label="Aggregate Output")

savefig(plt4c3c, "macro_hw7_code/4c3c_output_data.png")

plt4c3d = plot(background=:transparent, legend=:outerbottom, legendcolumns=2, xlabel="Time", ylabel="Output", title="Marginal Cost Data", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt4c3d, mc_firm_phipi, label="Firm Marginal Cost")
plot!(plt4c3d, mc_aggregate_phipi, label="Aggregate Marginal Cost")

savefig(plt4c3d, "macro_hw7_code/4c3d_marginal_cost_data.png")

println("With phipi = 10 and phiy = 0:")
println("Variance of inflation: $(var(pi_phipi)), old variance: $(var(piInit))")
println("Variance of output: $(var(y_phipi)), old variance: $(var(yInit))")
println("Variance of marginal cost: $(var(mc_firm_phipi)), old variance: $(var(mc_firm))")


# 5: Perfectly flexible price simulation
price_perfect = (1 - p.alpha) / (1 - p.alpha + p.alpha * p.epsilon) * (p.sigma .+ (p.varphi + p.alpha) / (1 - p.alpha) * (y_tildeInit)) .+ price_data

plt5 = plot(background=:transparent, legend=:outerbottom, legendcolumns=2, xlabel="Time", ylabel="Price", title="Perfectly Flexible Price Simulation", linewidth=2, linealpha=0.7, size=(800,200))
plot!(plt5, price_perfect, label="Perfectly Flexible Price")
plot!(plt5, price_data, label="Aggregate Price")

savefig(plt5, "macro_hw7_code/5_perfectly_flexible_price_simulation.png")




