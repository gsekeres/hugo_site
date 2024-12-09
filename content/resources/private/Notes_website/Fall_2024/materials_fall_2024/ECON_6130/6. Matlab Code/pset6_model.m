function [fyn, fxn, fypn, fxpn, fn, log_var] = pset6_model(param)

    %Steady State
    [ss, param] = pset5_model_ss(param);
    
    %Declare parameters
    bet = param.bet;
    sig = param.sig;
    alpha = param.alpha;
    deltak = param.deltak;
    deltan = param.deltan;
    phin = param.phin;
    chi = param.chi;
    eps = param.eps;
    rho = param.rho;
    
    %Declare symbols
    syms A A_p K K_p N_m N_m_p
    syms Yt Yt_p C C_p I I_p N N_p V V_p
    
    %Declare X and Y vectors
    X = [A K N_m];
    XP = [A_p K_p N_m_p];
    
    Y = [Yt C I N V];
    YP = [Yt_p C_p I_p N_p V_p];
    
    %Model Equations
    f(1) = 1 - bet * (C_p / C)^(-sig) * (A_p * alpha * (K_p / N_p)^(alpha - 1) + 1 - deltak);
    f(2) = phin / (eps * chi * V^(eps - 1)) - A * (1 - alpha) * (K / N)^alpha - bet * (C_p / C)^(-sig) * (phin / (eps * chi * V_p^(eps - 1))) * (1 - deltan);
    f(3) = Yt - A * K^alpha * N^(1 - alpha);
    f(4) = Yt - C - I - phin * V;
    f(5) = K_p - (1 - deltak) * K - I;
    f(6) = N - (1 - deltan) * N_m - chi * V^eps;
    f(7) = log(A_p) - rho * log(A);
    f(8) = N_m_p - N;
    
    %Chech computation of steady state numerically
    fnum = double(subs(f, [X Y XP YP], [ss ss]));
    disp('Checking steady state:');
    disp(fnum);
    
    nx = length(X);
    ny = length(Y); 
    %Log-linearize the model
    log_var = 1:(nx+ny);
    XY = [X,Y]; XY_p = [XP,YP];
    f = subs(f, [XY(log_var),XY_p(log_var)], exp([XY(log_var),XY_p(log_var)])); 
   
    ss(log_var) = log(ss(log_var));
    
    %Differentiate
    fx = jacobian(f, X);
    fy = jacobian(f, Y);
    fxp = jacobian(f, XP);
    fyp = jacobian(f, YP);
    
    %Compute numerical values
    fyn = double(subs(fy, [X Y XP YP], [ss ss]));
    fxn = double(subs(fx, [X Y XP YP], [ss ss]));
    fypn = double(subs(fyp, [X Y XP YP], [ss ss]));
    fxpn = double(subs(fxp, [X Y XP YP], [ss ss]));
    fn = double(subs(f, [X Y XP YP], [ss ss]));
    
end