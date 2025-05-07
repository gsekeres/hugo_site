mutable struct Parameters
    sigma::Float64
    varphi::Float64
    epsilon::Float64
    alpha::Float64
    beta::Float64
    theta::Float64
    phipi::Float64
    phiy::Float64
    rhoa::Float64
    sigmaa::Float64
    rhoz::Float64
    sigmaz::Float64
    kappa::Float64

    function Parameters(;sigma=2.0, varphi=3.0, epsilon=5.0, alpha=0.3, beta=0.99, theta=0.75, phipi=1.5, phiy=0.5, rhoa=0.8, sigmaa=1.0, rhoz=0.5, sigmaz=1.0)
        kappa = (sigma + (varphi + alpha) / (1 - alpha)) * (((1 - theta) * (1 - beta * theta)) / theta) * ((1 - alpha) / (1 - alpha + alpha * epsilon))
        return new(sigma, varphi, epsilon, alpha, beta, theta, phipi, phiy, rhoa, sigmaa, rhoz, sigmaz, kappa)
    end
end

"""
    undet_coef(p::Parameters) -> Vector{Float64}

Solve for the psis using the method of undetermined coefficients.
"""
function undet_coef(p::Parameters)
    A = [(1 - p.rhoa) (-p.kappa) 0 0;
         0 0 (1-p.rhoz) (-p.kappa);
         ((p.phipi - p.rhoa) / p.sigma) (2 - 2 * p.rhoa + p.phiy / p.sigma) 0 0;
         0 0 ((p.phipi - p.rhoz) / p.sigma) (1 - p.rhoz + p.phiy / p.sigma)]
    B = [0; 0; 0; (1 - p.rhoz) / p.sigma]
    return inv(A) * B
end

"""
    simulate(p::Parameters, T::Int) -> Vector{Float64}, Vector{Float64}, Vector{Float64}, Vector{Float64}

Simulate the model for T periods in a certain parameterization, returning vectors of 
    output, inflation, the real wage, and the nominal interest rate.
"""
function simulate(p::Parameters, T::Int; seed::Int=12345)
    Random.seed!(seed)
    # Initialize productivity and demand shocks
    a = zeros(T)
    z = zeros(T)
    for t in 2:T
        a[t] = p.rhoa * a[t-1] + randn() * sqrt(p.sigmaa)
        z[t] = p.rhoz * z[t-1] + randn() * sqrt(p.sigmaz)
    end

    psis = undet_coef(p)

    # Initialize output, inflation, real wage, and nominal interest rate
    y_tilde = zeros(T)
    y_n = zeros(T)
    y = zeros(T)
    pi = zeros(T)
    w = zeros(T)
    i = zeros(T)

    for t in 1:T
        y_tilde[t] = psis[2] * a[t] + psis[4] * z[t]
        y_n[t] = ((1 + p.varphi) / (p.sigma * (1 - p.alpha) + p.varphi + p.alpha)) * a[t]
        y[t] = y_tilde[t] + y_n[t]
        pi[t] = psis[1] * a[t] + psis[3] * z[t]
        w[t] = p.sigma * y[t] + p.varphi * ((y[t] - a[t]) / (1 - p.alpha))
        i[t] = -log(p.beta) + p.phipi * pi[t] + p.phiy * y_tilde[t]
    end

    return y, pi, w, i, a, z, y_tilde, y_n
end
