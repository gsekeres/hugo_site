function resid = pset6_residual(XYv, XYss, param, log_var)
    % Declare parameters
    bet = param.bet;
    sig = param.sig;
    alpha = param.alpha;
    deltak = param.deltak;
    deltan = param.deltan;
    phin = param.phin;
    chi = param.chi;
    eps = param.eps;
    rho = param.rho;
    siga = param.siga;

    % Take input argument, add back steady-state
    XYv = reshape(XYv, [8, numel(XYv)/8]) + XYss(:);

    % Put variables back into levels
    XYv(log_var,:) = exp(XYv(log_var,:));
    XYss(log_var) = exp(XYss(log_var)); 

    % Combine the (fixed) X0 with the guessed paths for X1, X2, ...
    A = [exp(log(XYss(1)) + siga), XYv(1,:)];
    K = [XYss(2), XYv(2,:)];
    N_m = [XYss(3), XYv(3,:)];

    % Combine the guessed paths for Y0, Y1, ... with (fixed) YT
    Yt = [XYv(4,:), XYss(4)];
    C = [XYv(5,:), XYss(5)];
    I = [XYv(6,:), XYss(6)];
    N = [XYv(7,:), XYss(7)];
    V = [XYv(8,:), XYss(8)];

    % Get the t+1 values
    A_p = A(2:end);
    K_p = K(2:end);
    N_m_p = N_m(2:end);
    C_p = C(2:end);
    N_p = N(2:end);
    V_p = V(2:end);

    % Get the t values
    A = A(1:end-1);
    K = K(1:end-1);
    N_m = N_m(1:end-1);
    Yt = Yt(1:end-1);
    C = C(1:end-1);
    I = I(1:end-1);
    N = N(1:end-1);
    V = V(1:end-1);

    % Model Equations
    resid = zeros(8, 500);  % Should be 500 periods
    resid(1,:) = 1 - bet .* (C_p ./ C).^(-sig) .* (A_p .* alpha .* (K_p ./ N_p).^(alpha - 1) + 1 - deltak);
    resid(2,:) = phin ./ (eps .* chi .* V.^(eps - 1)) - A .* (1 - alpha) .* (K ./ N).^alpha - bet .* ((C_p ./ C).^(-sig) .* phin ./ (eps .* chi .* V_p.^(eps - 1))) .* (1 - deltan);
    resid(3,:) = Yt - A .* K.^alpha .* N.^(1 - alpha);
    resid(4,:) = Yt - C - I - phin .* V;
    resid(5,:) = K_p - (1 - deltak) .* K - I;
    resid(6,:) = N - (1 - deltan) .* N_m - chi .* V.^eps;
    resid(7,:) = log(A_p) - rho .* log(A);
    resid(8,:) = N_m_p - N;
end