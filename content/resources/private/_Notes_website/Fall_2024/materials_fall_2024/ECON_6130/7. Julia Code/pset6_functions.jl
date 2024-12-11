"""
    crra_cd_residual(XYv, XYss, param)

This function returns the residual of a path guess, given the steady state values and parameters.
"""
function crra_cd_residual(XYv::Vector{Float64}, XYss::Vector{Float64}, param::Vector{Float64})
    # Declare parameters
    bet, sig, alpha, deltak, deltan, phin, chi, eps, rho = param[1:9]

    # Declare symbolic variables
    @variables A A_p K K_p N_m N_m_p
    @variables Yt Yt_p C C_p I I_p N N_p V V_p

    # Reshape XYv to match the dimensions of the model variables
    num_vars = length(XYss)
    num_periods = div(length(XYv), num_vars)
    XYv = reshape(XYv, num_vars, num_periods)

    # Initialize residual vector
    resid = zeros(8, num_periods)

    # Loop through each period to compute residuals
    for t = 1:num_periods
        # Extract current period variables
        if t == 1
            X = XYss[1:num_state]
        else
            X = XYv[1:num_state, t-1]
        end
        Y = XYv[num_state+1:end, t]

        if t == num_periods
            Y_p = XYss[num_state+1:end]
        else
            Y_p = XYv[num_state+1:end, t]
        end
        X_p = XYv[1:num_state, t]

        # Evaluate model equations
        current_resid = [
            1 - bet * (Y_p[2] / Y[2])^(-sig) * (X_p[1] * alpha * (X_p[2] / X_p[3])^(alpha - 1) + 1 - deltak),
            phin / (eps * chi * Y[5]^(eps - 1)) - X[1] * (1 - alpha) * (X[2] / X[3])^alpha - 
            bet * (Y_p[2] / Y[2])^(-sig) * (phin / (eps * chi * Y_p[5]^(eps - 1))) * (1 - deltan),
            Y[1] - X[1] * X[2]^alpha * X[3]^(1 - alpha),
            Y[1] - Y[2] - Y[3] - phin * Y[5],
            X_p[2] - (1 - deltak) * X[2] - Y[3],
            X[3] - (1 - deltan) * X_p[3] - chi * Y_p[5]^eps,
            log(A_p) - rho * log(A),
            N_m_p - N
        ]

        # Store residuals
        resid[:, t] = current_resid
    end

    # Vectorize the residuals
    return vec(resid)
end