using Distributions, LinearAlgebra, StatsBase, Plots

@time begin
# Import relevant functions
include("pset4_markov_functions_julia.jl")
include("pset4_value_functions_julia.jl")

# Simulate Markov process:
include("pset4_markov_julia.jl")

# Value Function Iteration:
include("pset4_value_julia.jl")

# Simulate model
include("pset4_growth_sim.jl")

end















