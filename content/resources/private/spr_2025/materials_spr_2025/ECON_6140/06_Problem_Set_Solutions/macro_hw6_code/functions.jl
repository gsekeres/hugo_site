mutable struct Parameters
    sigma::Float64
    phi::Float64
    alpha::Float64
    rhoalpha::Float64
    sigmaalpha::Float64
    beta::Float64
    psina::Float64
    psin::Float64
    psiya::Float64
    psiy::Float64
    psiomegaa::Float64
    psiomega::Float64

    function Parameters(;sigma=2.0, phi=3.0, alpha=0.3, rhoalpha=0.8, sigmaalpha=1.0, beta=0.99)
        denom = phi + alpha + sigma * (1 - alpha)
        psina = (1 - sigma) / denom
        psin = (log(1 - alpha)) / denom
        psiya = (1 + phi) / denom
        psiy = (1 - alpha) * psin
        psiomegaa = (phi + sigma) / denom
        psiomega = ((phi + sigma * (1 - alpha)) * log(1 - alpha)) / denom
        return new(sigma, phi, alpha, rhoalpha, sigmaalpha, beta, psina, psin, psiya, psiy, psiomegaa, psiomega)
    end
end
"""
    simulate(p::Parameters, T::Int; seed=...) -> Dict

Simulate T periods of the model. Returns a Dict with vectors of
{a, n, y, omega}. The user can specify a seed for reproducibility.
"""
function simulate(p::Parameters, T::Int; seed::Int=0)
    if seed != 0
        Random.seed!(seed)
    end
    a = zeros(T)
    n = zeros(T)
    y = zeros(T)
    omega = zeros(T)

    # For the shock process a_{t+1} = rho * a_t + e_{t+1}
    # with e_{t+1} ~ Normal(0, sigmaalpha^2).
    for t in 2:T
        shock = randn() * sqrt(p.sigmaalpha)
        a[t] = p.rhoalpha * a[t-1] + shock
    end

    # Now compute n, y, omega from the closed-form solutions:
    for t in 1:T
        n[t]      = p.psina    * a[t] + p.psin
        y[t]      = p.psiya    * a[t] + p.psiy
        omega[t]  = p.psiomegaa* a[t] + p.psiomega
    end

    return Dict(:a => a, :n => n, :y => y, :omega => omega)
end
"""
    compute_sample_moments(data::Dict) -> Dict

Given a Dict of time series (key => vector), compute:
- Variances
- Cross-correlations

Returns another Dict with those statistics.
"""
function compute_sample_moments(data::Dict)
    a = data[:a]
    n = data[:n]
    y = data[:y]
    omega = data[:omega]

    va = var(a)
    vn = var(n)
    vy = var(y)
    vomega = var(omega)

    M = hcat(n, y, omega)
    C = cor(Matrix(M))

    return Dict(
        :var => (vn, vy, vomega),
        :corr => C
    )
end

"""
    compute_irf(p::Parameters, horizon::Int) -> Dict

Computes impulse responses of n_t, y_t, omega_t to a one-time shock in epsilon_a.
The approach here:
1. Start with a(0) = 0, then at t=1 let epsilon_a = 1 (one-unit shock),
   for t>1 all shocks = 0.
2. Record a(t), then compute n(t), y(t), omega(t).
3. Return the deviations from the no-shock baseline.
"""
function compute_irf(p::Parameters, horizon::Int)
    a_irf = zeros(horizon)
    n_irf = zeros(horizon)
    y_irf = zeros(horizon)
    omega_irf = zeros(horizon)

    for t in 1:horizon
        a_current = p.rhoalpha^(t-1) * 1.0

        # Full levels with shock:
        n_shock = p.psina*a_current + p.psin
        y_shock = p.psiya*a_current + p.psiy
        omega_shock = p.psiomegaa*a_current + p.psiomega

        # Baseline levels (no shock) are:
        n_irf[t] = n_shock - p.psin
        y_irf[t] = y_shock - p.psiy
        omega_irf[t] = omega_shock - p.psiomega
        a_irf[t] = a_current
    end

    return Dict(:a => a_irf, :n => n_irf, :y => y_irf, :omega => omega_irf)
end