% MODEL_SS - Solves for the steady-state of our class model, taking data
% structure with parameter values as inputs
%
% usage:
%
% ss = model_ss(param)

function [Xss,Yss] = model_ss(param)

%Assign parameter values
passign(param);

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
Xss = [a k];


