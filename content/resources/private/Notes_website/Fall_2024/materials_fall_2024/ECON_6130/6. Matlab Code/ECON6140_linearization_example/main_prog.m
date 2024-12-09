%**************************************************************
% MAIN_PROG - Solves the neoclassical model with a random walk 
% TFP.
%
% Code by Ryan Chahrour, Cornell University, 2024
%**************************************************************


clear

%Load Parameters
param = parameters;

%Compute the first-order coefficiencients of the model
[fyn, fxn, fypn, fxpn, fn] = model(param);

%Compute the transition and policy functions, using code by
%Stephanie Schmitt-Grohé and Martín Uribe (and available on their website.)
[gx,hx]=gx_hx_alt(fyn,fxn,fypn,fxpn);

%Shock hits GAM, which is the first state
eta = [param.sige;0];

%Eigenvalues of hx
disp('Computing eigenvalues of hx');
disp(eig(hx))


