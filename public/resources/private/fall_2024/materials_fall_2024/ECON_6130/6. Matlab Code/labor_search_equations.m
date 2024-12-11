function f = labor_search_equations(param)

    %Declare parameters
    bet = param.bet;
    sig = param.sig;
    alpha = param.alpha;
    deltak = param.deltak;
    deltan = param.deltan;
    phin = param.phin;
    eps = param.eps;
    chi = param.chi;
    rho = param.rho;

    %Declare symbols
    syms A A_p K K_p N_m N_m_p
    syms Yt Yt_p C C_p I I_p N N_p V V_p

    %Model Equations
    f(1) = 1 - bet * (C_p / C)^(-sig) * (A_p * alpha * (K_p / N_p)^(alpha - 1) + 1 - deltak);
    f(2) = phin / (eps * chi * V^(eps - 1)) - A * (1 - alpha) * (K / N)^alpha - bet * (C_p / C)^(-sig) * (phin / (eps * chi * V_p^(eps - 1))) * (1 - deltan);
    f(3) = Yt - A * K^alpha * N^(1 - alpha);
    f(4) = Yt - C - I - phin * V;
    f(5) = K_p - (1 - deltak) * K - I;
    f(6) = N - (1 - deltan) * N_m - chi * V^eps;
    f(7) = log(A_p) - rho * log(A);
    f(8) = N_m_p - N;

    %Return the equations
    f = [f(1) f(2) f(3) f(4) f(5) f(6) f(7) f(8)];
end