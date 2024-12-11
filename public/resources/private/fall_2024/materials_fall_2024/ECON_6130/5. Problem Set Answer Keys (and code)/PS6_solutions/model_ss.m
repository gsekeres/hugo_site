% MODEL_SS - Solves for the steady-state of our class model, taking data
% structure with parameter values as inputs
%
% usage:
%
% ss = model_ss(param)

function [Xss,Yss] = model_ss(param)

bet  = param.bet;
sig  = param.sig;
alph = param.alph;
delk = param.delk;
deln = param.deln;
phin = param.phin;
veps = param.veps;
chi  = param.chi;

k_n = ((1/bet - 1 + delk)/alph)^(1/(alph-1));  %Eq 14 in notes
v   = ((veps*chi/phin)*(1-alph)/(1-bet*(1-deln))*k_n^alph)^(1/(1-veps)); %Eq 15 in notes
n   = chi/deln*v^veps;
k   = k_n*n;
inv = delk*k;
y   = k^alph*n^(1-alph);
c   = y - inv - phin*v;

%Output argugment
Xss = [1 k n];
Yss = [y,c,inv,n,v];

