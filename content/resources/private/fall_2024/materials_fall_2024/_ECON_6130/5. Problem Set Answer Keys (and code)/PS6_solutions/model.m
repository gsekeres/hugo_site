% MODEL_LINEAR - Linearized version of the RBC model with search
%
% usage:
%
% [fy, fx, fyp, fxp] = model(param)
%
% where
%
% param = a parameters object, created in parameters.m
%
% NOTES: This program, which generates the model matrices in canonical form,
%        requires the MATLAB symbolic toolbox! The algorithm used to solve 
%        the model, however, is numerical and requires no m-files
%        beyond those that appear in this directory.
%
% Code by Ryan Chahrour, Cornell University, 2023
 

function [fyn, fxn, fypn, fxpn, fn] = model(param)

%Steady State
[Xss,Yss] = model_ss(param);
ss = [Yss,Xss];

%Declare parameters
bet  = param.bet;
sig  = param.sig;
alph = param.alph;
delk = param.delk;
deln = param.deln;
phin = param.phin;
veps = param.veps;
chi  = param.chi;
rho  = param.rho;
siga = param.siga;

%Declare Needed Symbols
syms A A_p K K_p NL NL_p
syms C C_p N N_p GDP GDP_p V V_p I I_p

%Declare X and Y vectors
X  = [A   K   NL  ];
XP = [A_p K_p NL_p];

Y  = [GDP   C    I   N    V];
YP = [GDP_p C_p  I_p N_p  V_p] ;


%Model Equations
f = sym(zeros(8,1));
f(1) = GDP - A*K^alph*N^(1-alph);
f(2) = (1-delk)*K + I - K_p;
f(3) = N - (1-deln)*NL - chi*V^veps;
f(4) = GDP - C - I - phin*V;
f(5) = 1-bet*(C_p/C)^-sig*(A_p*alph*(K_p/N_p)^(alph-1) + 1 -delk);
f(6) = phin/(veps*chi*V^(veps-1)) - A*(1-alph)*(K/N)^alph - bet*(C_p/C)^-sig* phin/(veps*chi*V_p^(veps-1))*(1-deln);
f(7) = log(A_p) - rho*log(A);

%Linking equation
f(8) = NL_p-N;

%Check Computation of Steady-State Numerically
fnum = double(subs(f, [Y X YP XP], [ss, ss]));
disp('Checking steady-state equations:')
disp(fnum);

%Log-linear approx
log_var = [1:8];%[X Y XP YP];
YX = [Y,X]; YX_p = [YP,XP];
f = subs(f, [YX(log_var),YX_p(log_var)], exp([YX(log_var),YX_p(log_var)])); 
   
ss(log_var) = log(ss(log_var));

%Differentiate
fx  = jacobian(f,X);
fy  = jacobian(f,Y);
fxp = jacobian(f,XP);
fyp = jacobian(f,YP);

%Compute numerical values
fn  =  double(subs(f  , [Y X YP XP], [ss, ss]));
fxn =  double(subs(fx , [Y X YP XP], [ss, ss]));
fyn =  double(subs(fy , [Y X YP XP], [ss, ss]));
fxpn = double(subs(fxp, [Y X YP XP], [ss, ss]));
fypn = double(subs(fyp, [Y X YP XP], [ss, ss]));
