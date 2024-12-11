"""
    crra_cd_ss(param)

Compute the steady state of the CRRA-CD model.
param = [beta, sig, alpha, deltak, deltan, phin, chi, eps, rho, siga]
"""
function crra_cd_ss(param::Vector{Float64})
    kn = ((1/param[1] - 1 + param[4]) / param[3])^(1 / (param[3] - 1))
    v = (((param[8]*param[7]) / param[6]) * (1 - param[3]) / (1 - param[1] * (1 - param[5])) * kn ^ param[3])^(1 / (1 - param[8]))
    n = param[7] * v ^ param[8] / param[5]
    k = kn * n
    y = k^param[3] * n^(1-param[3])
    i = param[4] * k
    c = y - i - param[6] * v
    return [1 k n y c i n v]
end

"""
    crra_cd_model(param)

Compute the first-order coefficients of the CRRA-CD model.
param = [beta, sig, alpha, deltak, deltan, phin, chi, eps, rho, siga]
"""
function crra_cd_model(param::Vector{Float64}; verbose::Bool=true)
    # Steady State
    ss = crra_cd_ss(param)
    
    # Convert ss to vector
    ss = vec(ss)

    # Declare parameters
    bet, sig, alpha, deltak, deltan, phin, chi, eps, rho = param[1:9]

    # Declare symbolic variables
    @variables A A_p K K_p N_m N_m_p
    @variables Yt Yt_p C C_p I I_p N N_p V V_p

    # Declare X and Y vectors
    X = [A, K, N_m]
    XP = [A_p, K_p, N_m_p]
    Y = [Yt, C, I, N, V]
    YP = [Yt_p, C_p, I_p, N_p, V_p]

    # Model Equations
    f = [
        1 - bet * (C_p / C)^(-sig) * (A_p * alpha * (K_p / N_p)^(alpha - 1) + 1 - deltak),
        phin / (eps * chi * V^(eps - 1)) - A * (1 - alpha) * (K / N)^alpha - 
            bet * (C_p / C)^(-sig) * (phin / (eps * chi * V_p^(eps - 1))) * (1 - deltan),
        Yt - A * K^alpha * N^(1 - alpha),
        Yt - C - I - phin * V,
        K_p - (1 - deltak) * K - I,
        N - (1 - deltan) * N_m - chi * V^eps,
        log(A_p) - rho * log(A),
        N_m_p - N
    ]

    # Check steady state
    all_vars = vcat(X, Y, XP, YP)
    ss_double = vcat(ss, ss)  # Changed from vcat(ss; ss)
    ss_vals = Dict(zip(all_vars, ss_double))
    fnum = [substitute(fi, ss_vals) for fi in f]
    if verbose
        println("Checking steady state:")
        println(fnum)
    end

    # Log-linearize the model
    log_vars = Dict(v => exp(v) for v in all_vars)
    f = [substitute(fi, log_vars) for fi in f]
    ss = log.(ss)
    ss_double = vcat(ss, ss)  # Changed from vcat(ss; ss)
    ss_vals = Dict(zip(all_vars, ss_double))

    # Compute Jacobians
    fx = Symbolics.jacobian(f, X)
    fy = Symbolics.jacobian(f, Y)
    fxp = Symbolics.jacobian(f, XP)
    fyp = Symbolics.jacobian(f, YP)

    # Evaluate at steady state
    fxn = Float64.(Symbolics.value.(substitute.(fx, Ref(ss_vals))))
    fyn = Float64.(Symbolics.value.(substitute.(fy, Ref(ss_vals))))
    fxpn = Float64.(Symbolics.value.(substitute.(fxp, Ref(ss_vals))))
    fypn = Float64.(Symbolics.value.(substitute.(fyp, Ref(ss_vals))))
    fn = Float64.(Symbolics.value.(substitute.(f, Ref(ss_vals))))

    return fyn, fxn, fypn, fxpn, fn
end
"""
    gx_hx(fyn, fxn, fypn, fxpn, stake)

Compute the gx and hx matrices of the CRRA-CD model.
"""
function gx_hx(fyn::Matrix{Float64}, fxn::Matrix{Float64}, 
    fypn::Matrix{Float64}, fxpn::Matrix{Float64}; 
    stake::Real=1.0, verbose::Bool=true)
# Initialize exitflag
exitflag = 1

# Create system matrices A, B
A = [-fxpn -fypn]
B = [fxn fyn]
NK = size(fxn, 2)

# Complex Schur Decomposition
F = schur(A, B)

# Pick non-explosive (stable) eigenvalues
slt = abs.(diag(F.T)) .< stake .* abs.(diag(F.S))
nk = sum(slt)

# Reorder the system with stable eigenvalues in upper-left
F = ordschur(F, slt)

# Get the Z matrix from the decomposition
Z = F.Z

# Split up the results appropriately
z21 = Z[nk+1:end, 1:nk]
z11 = Z[1:nk, 1:nk]
s11 = F.S[1:nk, 1:nk]
t11 = F.T[1:nk, 1:nk]

# Catch cases with no / multiple solutions
if nk > NK
    verbose && @warn "The Equilibrium is Locally Indeterminate"
    exitflag = 2
    return zeros(size(z21)), zeros(size(z11)), exitflag
elseif nk < NK
    verbose && @warn "No Local Equilibrium Exists"
    exitflag = 0
    return zeros(size(z21)), zeros(size(z11)), exitflag
elseif rank(z11) < nk
    verbose && @warn "Invertibility condition violated"
    exitflag = 3
    return zeros(size(z21)), zeros(size(z11)), exitflag
end

# Compute the Solution
    try
        z11i = z11 \ I(nk)
        gx = real(z21 * z11i)
        hx = real(z11 * (s11 \ t11) * z11i)
        return gx, hx, exitflag
    catch e
        if isa(e, SingularException)
            verbose && @warn "Singular matrix encountered in computation"
            exitflag = 3
            return zeros(size(z21)), zeros(size(z11)), exitflag
        else
            rethrow(e)
        end
    end
end
