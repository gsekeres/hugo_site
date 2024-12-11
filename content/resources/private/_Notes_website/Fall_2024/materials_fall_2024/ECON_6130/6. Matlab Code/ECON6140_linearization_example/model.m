% MODEL_LINEAR - Linearized version of the simple RBC model.
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
% Code by Ryan Chahrour, 2023
 

function [fyn, fxn, fypn, fxpn, fn] = model(param)

%Steady State
[ss, param] = model_ss(param);

%Declare parameters
bet = param.bet;  %Never call anything beta...it's a matlab function
gam = param.gam;  %Average gross growth rate of TFP
chi = param.chi;  %Disutility of labor
del = param.del;  %Depreciation Rate
alph= param.alph; %Capital Share

%Declare Needed Symbols
syms GAM GAM_p K K_p
syms C C_p H H_p W W_p R R_p I I_p

%Declare X and Y vectors
X  = [GAM   K];
XP = [GAM_p K_p];

Y  = [C   H   W   R   I];
YP = [C_p H_p W_p R_p I_p] ;


%Model Equations
f(1) = C-W/chi;
f(2) = 1-bet*C/C_p*GAM^-1*(R_p+1-del);
f(3) = R - alph*K^(alph-1)*(GAM*H)^(1-alph);
f(4) = W - (1-alph)*K^alph*(GAM*H)^-alph*GAM;
f(5) = (1-del)*K + I - K_p*GAM;
f(6) = C+I- K^alph*(GAM*H)^(1-alph);
f(7) = log(GAM_p/gam) - .95*log(GAM/gam);

%Check Computation of Steady-State Numerically
fnum = double(subs(f, [Y X YP XP], [ss, ss]));
disp('Checking steady-state equations:')
disp(fnum);

%Log-linear approx
var_list = [Y,X]; var_list_p = [YP,XP];

log_var = 1:length(var_list);

disp(['logged variables: ' char(var_list(log_var))])
f = subs(f, [var_list(log_var),var_list_p(log_var)], exp([var_list(log_var),var_list_p(log_var)])); 
   
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
