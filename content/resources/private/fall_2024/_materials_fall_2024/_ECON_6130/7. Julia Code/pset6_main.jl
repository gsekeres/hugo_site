using LinearAlgebra, Symbolics, Plots, Random, Statistics, StatsBase

# Load functions
include("pset6_functions.jl")
include("pset5_functions.jl")

@time begin
# Set the parameters
param = [0.99, 2.00, 0.30, 0.03, 0.10, 0.50, 1.00, 0.25, 0.95, 0.01]

# Declare parameters
bet, sig, alpha, deltak, deltan, phin, chi, eps, rho = param[1:9]

# Compute the steady state
XYss = crra_cd_ss(param)

# Find linearized policy functions
[fyn, fxn, fypn, fxpn, ~] = crra_cd_model(param)
[gx, hx] = gx_hx(fyn, fxn, fypn, fxpn)

# Initialize shock
eta = zeros(3,3)
eta[1,1] = param[10]

# Timing of shock
T = 501

# Initialize IRF matrices
IRF_x = zeros(3,T)
IRF_y = zeros(5,T) 

# Compute IRFs
for i = 1:T
    IRF_x[:,i] = hx^i * eta * [1 0 0]'
    IRF_y[:,i] = gx * hx^i * eta * [1 0 0]'
end


end