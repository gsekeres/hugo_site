addpath('/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Matlab/pset7_helper_functions')

param = pset7_parameters;

%Declare model variables
declare A K N_m;
X = D; XP = make_prime(X);

declare Yt C I N V VAL;
Y = D; YP = make_prime(Y);

ny = length(Y);
nx = length(X);

%Declare model parameters & values
pnames = fieldnames(param);
declare(pnames{:});
pvec = D;
pnum = struct2array(param);

%Model Equations
f = sym([]);
f(end+1) = 1 - bet * (C_p / C)^(-sig) * (A_p * alpha * (K_p / N_p)^(alpha - 1) + 1 - deltak);
f(end+1) = phin / (eps * chi * V^(eps - 1)) - A * (1 - alpha) * (K / N)^alpha - bet * (C_p / C)^(-sig) * (phin / (eps * chi * V_p^(eps - 1))) * (1 - deltan);
f(end+1) = Yt - A * K^alpha * N^(1 - alpha);
f(end+1) = Yt - C - I - phin * V;
f(end+1) = K_p - (1 - deltak) * K - I;
f(end+1) = N - (1 - deltan) * N_m - chi * V^eps;
f(end+1) = log(A_p) - rho * log(A);
f(end+1) = N_m_p - N;
f(end+1) = VAL - (C ^ (1 - sig)) / (1 - sig) - bet*VAL_p;

disp(['neq    :' num2str(length(f))])
disp(['ny + nx:' num2str(ny+nx)])

%Steady state, use closed form expressions for the ss values.
kn = ((1/bet - 1 + deltak) / alpha)^(1 / (alpha - 1));
v = (((eps*chi) / phin) * (1 - alpha) / (1 - bet * (1 - deltan)) * kn ^ alpha)^(1 / (1 - eps));
n = chi * v ^ eps / deltan;
k = kn * n;
y = k^alpha * n^(1-alpha);
i = deltak * k;
c = y - i - phin * v;
a = 1;
val = (1 / (1 - bet)) * (c ^ (1 - sig)) / (1 - sig);

%Y and X vectors with SS values
Yss = [y c i n v val];
Xss = [a k n];

%Log-linear approx (Pure linear if log_var = [])
xlog = [];%1:length(X);
ylog = [];%1:length(Y); ylog(end) = []; %V in negative in SS
log_var = [X(xlog) Y(ylog) XP(xlog) YP(ylog)];

Yss(ylog) = log(Yss(ylog));
Xss(xlog) = log(Xss(xlog));

f = subs(f, log_var, exp(log_var));

% Get the derivative matrices
fx  = subs(jacobian(f,X)  ,[YP,XP,Y,X],[Yss,Xss,Yss,Xss]);
fy  = subs(jacobian(f,Y)  ,[YP,XP,Y,X],[Yss,Xss,Yss,Xss]);
fxp = subs(jacobian(f,XP) ,[YP,XP,Y,X],[Yss,Xss,Yss,Xss]);
fyp = subs(jacobian(f,YP) ,[YP,XP,Y,X],[Yss,Xss,Yss,Xss]);
fv  = subs(f              ,[YP,XP,Y,X],[Yss,Xss,Yss,Xss]);
matlabFunction(fy,fx,fyp,fxp,fv,[Yss,Xss],'vars',{pvec},'file', '/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Matlab/pset7_model_df.m', 'optimize', false);


make_index([Y,X]);