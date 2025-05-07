using Random, Statistics, Plots
include("functions.jl")

# Make the plots look pretty
pyplot()
PyPlot.rc("text", usetex=true)
PyPlot.rc("font", family="serif")
PyPlot.matplotlib.rcParams["mathtext.fontset"] = "cm"

# Preliminaries
println("Check different parameters:")
parameters1 = Parameters()
parameters4 = Parameters(sigma = 0.5)
parameters5 = Parameters(phi = 10)
parameters6 = Parameters(alpha = 0.5)

# Simulation horizon
T = 100

println("Initial: sigma =$(parameters1.sigma) & phi = $(parameters1.phi) & alpha = $(parameters1.alpha) & rhoalpha = $(parameters1.rhoalpha) & sigmaalpha = $(parameters1.sigmaalpha) & beta = $(parameters1.beta)")
println("Part 4: sigma = $(parameters4.sigma) & phi = $(parameters4.phi) & alpha = $(parameters4.alpha) & rhoalpha = $(parameters4.rhoalpha) & sigmaalpha = $(parameters4.sigmaalpha) & beta = $(parameters4.beta)")
println("Part 5: sigma = $(parameters5.sigma) & phi = $(parameters5.phi) & alpha = $(parameters5.alpha) & rhoalpha = $(parameters5.rhoalpha) & sigmaalpha = $(parameters5.sigmaalpha) & beta = $(parameters5.beta)")
println("Part 6: sigma = $(parameters6.sigma) & phi = $(parameters6.phi) & alpha = $(parameters6.alpha) & rhoalpha = $(parameters6.rhoalpha) & sigmaalpha = $(parameters6.sigmaalpha) & beta = $(parameters6.beta)")
println("psina: $(round(parameters1.psina, digits=4)) & $(round(parameters4.psina, digits=4)) & $(round(parameters5.psina, digits=4)) & $(round(parameters6.psina, digits=4))")
println("psin: $(round(parameters1.psin, digits=4)) & $(round(parameters4.psin, digits=4)) & $(round(parameters5.psin, digits=4)) & $(round(parameters6.psin, digits=4))")
println("psiya: $(round(parameters1.psiya, digits=4)) & $(round(parameters4.psiya, digits=4)) & $(round(parameters5.psiya, digits=4)) & $(round(parameters6.psiya, digits=4))")
println("psiy: $(round(parameters1.psiy, digits=4)) & $(round(parameters4.psiy, digits=4)) & $(round(parameters5.psiy, digits=4)) & $(round(parameters6.psiy, digits=4))")
println("psiomegaa: $(round(parameters1.psiomegaa, digits=4)) & $(round(parameters4.psiomegaa, digits=4)) & $(round(parameters5.psiomegaa, digits=4)) & $(round(parameters6.psiomegaa, digits=4))")
println("psiomega: $(round(parameters1.psiomega, digits=4)) & $(round(parameters4.psiomega, digits=4)) & $(round(parameters5.psiomega, digits=4)) & $(round(parameters6.psiomega, digits=4))")


# Question 2
simdata1 = simulate(parameters1, T, seed=1234)
varcorr1 = compute_sample_moments(simdata1)
println("variances (n, y, omega): $(round.(varcorr1[:var], digits=4))")
println("correlations (n, y, omega) x (n, y, omega): $(round.(varcorr1[:corr], digits=4))")
n_data1 = simdata1[:n]
y_data1 = simdata1[:y]
omega_data1 = simdata1[:omega]

p11 = plot(background=:transparent)
plot!(p11, n_data1, label="\$n\$", color=:blue)
plot!(p11, y_data1, label="\$y\$", color=:red)
plot!(p11, omega_data1, label="\$\\omega\$", color=:green)

savefig(p11, "macro_hw6_code/q2_simdata.png")

irf1 = compute_irf(parameters1, 20)

p12 = plot(background=:transparent)
plot!(p12, irf1[:a], label="\$a\$", color=:blue)
plot!(p12, irf1[:n], label="\$n\$", color=:red)
plot!(p12, irf1[:y], label="\$y\$", color=:green)
plot!(p12, irf1[:omega], label="\$\\omega\$", color=:purple)

savefig(p12, "macro_hw6_code/q2_irf.png")


# Question 4
simdata4 = simulate(parameters4, T, seed=1234)
varcorr4 = compute_sample_moments(simdata4)
println("variances (n, y, omega): $(round.(varcorr4[:var], digits=4))")
println("correlations (n, y, omega) x (n, y, omega): $(round.(varcorr4[:corr], digits=4))")
n_data4 = simdata4[:n]
y_data4 = simdata4[:y]
omega_data4 = simdata4[:omega]

p41 = plot(background=:transparent)
plot!(p41, n_data4, label="\$n\$", color=:blue)
plot!(p41, y_data4, label="\$y\$", color=:red)
plot!(p41, omega_data4, label="\$\\omega\$", color=:green)

savefig(p41, "macro_hw6_code/q4_simdata.png")

irf4 = compute_irf(parameters4, 20)

p42 = plot(background=:transparent)
plot!(p42, irf4[:a], label="\$a\$", color=:blue)
plot!(p42, irf4[:n], label="\$n\$", color=:red)
plot!(p42, irf4[:y], label="\$y\$", color=:green)
plot!(p42, irf4[:omega], label="\$\\omega\$", color=:purple)

savefig(p42, "macro_hw6_code/q4_irf.png")

# Question 5
simdata5 = simulate(parameters5, T, seed=1234)
varcorr5 = compute_sample_moments(simdata5)
println("variances (n, y, omega): $(round.(varcorr5[:var], digits=4))")
println("correlations (n, y, omega) x (n, y, omega): $(round.(varcorr5[:corr], digits=4))")
n_data5 = simdata5[:n]
y_data5 = simdata5[:y]
omega_data5 = simdata5[:omega]

p51 = plot(background=:transparent)
plot!(p51, n_data5, label="\$n\$", color=:blue)
plot!(p51, y_data5, label="\$y\$", color=:red)
plot!(p51, omega_data5, label="\$\\omega\$", color=:green)

savefig(p51, "macro_hw6_code/q5_simdata.png")

irf5 = compute_irf(parameters5, 20)

p52 = plot(background=:transparent)
plot!(p52, irf5[:a], label="\$a\$", color=:blue)
plot!(p52, irf5[:n], label="\$n\$", color=:red)
plot!(p52, irf5[:y], label="\$y\$", color=:green)
plot!(p52, irf5[:omega], label="\$\\omega\$", color=:purple)

savefig(p52, "macro_hw6_code/q5_irf.png")

# Question 6
simdata6 = simulate(parameters6, T, seed=1234)
varcorr6 = compute_sample_moments(simdata6)
println("variances (n, y, omega): $(round.(varcorr6[:var], digits=4))")
println("correlations (n, y, omega) x (n, y, omega): $(round.(varcorr6[:corr], digits=4))")
n_data6 = simdata6[:n]
y_data6 = simdata6[:y]
omega_data6 = simdata6[:omega]

p61 = plot(background=:transparent)
plot!(p61, n_data6, label="\$n\$", color=:blue)
plot!(p61, y_data6, label="\$y\$", color=:red)
plot!(p61, omega_data6, label="\$\\omega\$", color=:green)

savefig(p61, "macro_hw6_code/q6_simdata.png")

irf6 = compute_irf(parameters6, 20)

p62 = plot(background=:transparent)
plot!(p62, irf6[:a], label="\$a\$", color=:blue)
plot!(p62, irf6[:n], label="\$n\$", color=:red)
plot!(p62, irf6[:y], label="\$y\$", color=:green)
plot!(p62, irf6[:omega], label="\$\\omega\$", color=:purple)

savefig(p62, "macro_hw6_code/q6_irf.png")


# Question 7
println("STD y: $(round(std(y_data1), digits=4))")

parameters_y = Parameters(sigma=0.33)
simdata_y = simulate(parameters_y, T, seed=1234)
println("STD y: $(round(std(simdata_y[:y]), digits=4))")

