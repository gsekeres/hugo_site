"""
    tauchen(persistence, lr_var, lr_mean, e_mean, size_space)

Implements Tauchen's method for a size_space-point Markov chain approximation 
of a persistent process with a given long-run mean and variance, and 
normally-distributed noise.

Returns the state space and the transition matrix.

Needs: Distributions

"""
function tauchen(persistence, lr_var, lr_mean, e_mean, size_space)
    @assert size_space % 2 == 1
    # Compute variance of shock
    e_var = (1 - persistence ^ 2) * lr_var

    # Make the state space
    z = collect(range(lr_mean - ((size_space - 1) / 2) * sqrt(lr_var), lr_mean + ((size_space - 1) / 2) * sqrt(lr_var), length = size_space))

    # Initialize transition matrix
    P = zeros(size_space, size_space)

    # Compute transition probabilities
    # Note: Currently O(n^2). Doesn't matter for small sizes, but could likely be improved to O(n) if more fine grid.
    for i in 1:size_space
        for j in 1:size_space
            if j == 1
                P[i,j] = cdf(Normal(e_mean, sqrt(e_var)), (z[j] - persistence * z[i] + 0.5 * sqrt(lr_var)))
            elseif j == size_space
                P[i,j] = 1 - cdf(Normal(e_mean, sqrt(e_var)), (z[j] - persistence * z[i] - 0.5 * sqrt(lr_var)))
            else
                P[i,j] = cdf(Normal(e_mean, sqrt(e_var)), (z[j] - persistence * z[i] + 0.5 * sqrt(lr_var))) - cdf(Normal(e_mean, sqrt(e_var)),  (z[j] - persistence * z[i] - 0.5 * sqrt(lr_var)))
            end
        end
    end

    return z, P
end

"""
    stationary_distribution(P)

Given a transition matrix, return the stationary distribution.

Needs: LinearAlgebra
"""
function stationary_distribution(P)
    # Find the eigenvector corresponding to eigenvalue 1
    vals, vecs = eigen(P')
    stat_dist = vecs[:, argmax(vals)]

    # Normalize the eigenvector
    stat_dist = stat_dist ./ sum(stat_dist)

    # Return the real part
    return real(stat_dist)
end


"""
    simulate_markov_chain(P, z, N, stationary_dist)

Given a state space and a transition matrix, simulate a Markov chain for N periods, starting
from a stationary distribution.

Returns the simulated chain.

Needs: StatsBase

"""
function simulate_markov_chain(P, z, N, stationary_dist)
    # Initialize state vector
    y_state = zeros(Int, N)  # Index of the realization of the variable
    y_val = zeros(N)         # Value of the realization of the variable

    # First period: use stationary distribution
    num = rand()
    cumulative_sum = 0.0
    for j in 1:eachindex(stationary_dist)
        cumulative_sum += stationary_dist[j]
        if num <= cumulative_sum
            y_state[1] = j
            y_val[1] = z[j]
            break
        end
    end

    # Following periods: use transition matrix
    for i in 2:N
        num = rand()  # Random variable drawn from uniform distribution
        cumulative_sum = 0.0
        for j in 1:eachindex(z)
            cumulative_sum += P[y_state[i-1], j]
            if num <= cumulative_sum
                y_state[i] = j
                y_val[i] = z[j]
                break
            end
        end
    end

    return y_val
end