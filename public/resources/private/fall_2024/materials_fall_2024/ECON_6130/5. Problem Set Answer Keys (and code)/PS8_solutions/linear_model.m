%**************************************************************
% Solve the linear RBC model using the symbolic toolbox
%**************************************************************
addpath('helper_functions')

param = parameters;

%Declare model variables
declare A   K   NL  ;
X = V; XP = make_prime(X);

declare GDP   C    I   N    VAC VAL;
Y = V; YP = make_prime(Y);

ny = length(Y);
nx = length(X);

%Declare model parameters & values
pnames = fieldnames(param);
declare(pnames{:});
pvec = V;
pnum = struct2array(param);

%Model Equations
f = sym([]);
f(end+1) = GDP - A*K^alph*N^(1-alph);
f(end+1) = (1-delk)*K + I - K_p;
f(end+1) = N - (1-deln)*NL - chi*VAC^veps;
f(end+1) = GDP - C - I - phin*VAC;
f(end+1) = 1-bet*(C_p/C)^-sig*(A_p*alph*(K_p/N_p)^(alph-1) + 1 -delk);
f(end+1) = phin/(veps*chi*VAC^(veps-1)) - A*(1-alph)*(K/N)^alph - bet*(C_p/C)^-sig* phin/(veps*chi*VAC_p^(veps-1))*(1-deln);
f(end+1) = log(A_p) - rho*log(A);
f(end+1) = VAL - C^(1-sig)/(1-sig) - bet*VAL_p;

%Linking equation
f(end+1) = NL_p-N;

disp(['neq    :' num2str(length(f))])
disp(['ny + nx:' num2str(ny+nx)])

%Steady state, use closed form expressions for the ss values.
k_n = ((1/bet - 1 + delk)/alph)^(1/(alph-1));  %Eq 14 in notes
v   = ((veps*chi/phin)*(1-alph)/(1-bet*(1-deln))*k_n^alph)^(1/(1-veps)); %Eq 15 in notes
n   = chi/deln*v^veps;
k   = k_n*n;
inv = delk*k;
y   = k^alph*n^(1-alph);
c   = y - inv - phin*v;
val = 1/(1-bet)*c^(1-sig)/(1-sig);

Yss = [y,c,inv,n,v,val];
Xss = [1 k n];


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
matlabFunction(fy,fx,fyp,fxp,fv,[Yss,Xss],'vars',{pvec},'file', 'model_df.m', 'optimize', false);


make_index([Y,X]);