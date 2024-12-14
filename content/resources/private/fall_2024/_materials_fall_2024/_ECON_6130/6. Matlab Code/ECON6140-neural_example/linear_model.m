%**************************************************************
% Solve the linear RBC model using the symbolic toolbox
%**************************************************************
addpath('helper_functions')

param = parameters;

%Declare states for news process
horiz = 2; %Horizon of news
syms('EPS',[1,horiz])
EPSP = make_prime(EPS);

%Declare remaining model variables 
% (note its convenient, but not essential to define lagged A as the state, along with the news shocks)
declare K A;
X = [V,EPS]; XP = make_prime(X);

declare C H W R I VAL; 
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
f(end+1) = C-W/chi;
f(end+1) = 1-bet*(C/C_p)^sigma*(R_p+1-del);
f(end+1) = R - alph*A*(K/H)^(alph-1);
f(end+1) = W - (1-alph)*A*(K/H)^alph;
f(end+1) = (1-del)*K + I - K_p;
f(end+1) = C+I- A*K^alph*H^(1-alph);
f(end+1) = VAL - (C^(1-sigma)/(1-sigma) - chi*H) - bet*VAL_p;

if horiz ==0
    f(end+1) = log(A_p) - rho*log(A);
else
    f(end+1) = log(A_p) - rho*log(A) - log(EPS(1));

    %Advance news period by period
    for jj =1:horiz-1
        f(end+1) =   EPSP(jj) - EPS(jj+1);
    end
    f(end+1) = log(EPSP(end));  %This is variable that get's the shock
end

disp(['neq    :' num2str(length(f))])
disp(['ny + nx:' num2str(ny+nx)])

%Steady state, use closed form expressions for the ss values.
r  = (1/(bet*gam^(1/(1-alph))))-1+del;
kh = (r/(alph*gam))^(1/(alph-1));
w  = (1-alph)*(r/alph)^(alph/(alph-1));
ik = (1-(1-del)/(gam^(1/(1-alph))));
c  = w/chi;
k  = c/(gam^(alph/(alph-1))*kh^(alph-1) - ik);
i  = ik*k;
h  = kh^-1*k;
v  = 1/(1-bet)*(log(c)-chi*h);
a  = 1;

%Y and X vectors with SS values
Yss = [c h w r i v];
Xss = [k a ones(1,horiz)];

%Log-linear approx (Pure linear if log_var = [])
xlog = [2:horiz+2];%1:length(X);
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