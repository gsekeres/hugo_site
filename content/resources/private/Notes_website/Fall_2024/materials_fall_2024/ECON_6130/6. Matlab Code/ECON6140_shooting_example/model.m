% MODEL_LINEAR - Linearized version of the RBC model
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
 

function [fyn, fxn, fypn, fxpn, fn, log_var] = model(param)

%Steady State
[Xss,Yss] = model_ss(param);
ss = [Xss Yss];

%Declare model variables
declare A K;
X = V; XP = make_prime(X);

declare C H W R I VAL;
Y = V; YP = make_prime(Y);

ny = length(Y);
nx = length(X);

%Declare model parameters & values
passign(param)

%Model Equations
f = sym([]);
f(end+1) = C-W/chi;
f(end+1) = 1-bet*C/C_p*(R_p+1-del);
f(end+1) = R - alph*A*(K/H)^(alph-1);
f(end+1) = W - (1-alph)*A*(K/H)^alph;
f(end+1) = (1-del)*K + I - K_p;
f(end+1) = C+I- A*K^alph*H^(1-alph);
f(end+1) = VAL - (log(C) - chi*H) - bet*VAL_p;
f(end+1) = log(A_p) - rho_a*log(A);

disp(['neq    :' num2str(length(f))])
disp(['ny + nx:' num2str(ny+nx)])

%Check Computation of Steady-State Numerically
fnum = double(subs(f, [X Y, XP YP], [ss, ss]));
disp('Checking steady-state equations:')
disp(fnum);

%Log-linear approx
log_var = [1:(nx+ny-1)];
XY = [X,Y]; XY_p = [XP,YP];
f = subs(f, [XY(log_var),XY_p(log_var)], exp([XY(log_var),XY_p(log_var)])); 
   
ss(log_var) = log(ss(log_var));

%Differentiate
fx  = jacobian(f,X);
fy  = jacobian(f,Y);
fxp = jacobian(f,XP);
fyp = jacobian(f,YP);

%Compute numerical values
fn  =  double(subs(f  , [X Y XP YP], [ss, ss]));
fxn =  double(subs(fx , [X Y XP YP], [ss, ss]));
fyn =  double(subs(fy , [X Y XP YP], [ss, ss]));
fxpn = double(subs(fxp, [X Y XP YP], [ss, ss]));
fypn = double(subs(fyp, [X Y XP YP], [ss, ss]));
