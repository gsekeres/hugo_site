% MODEL_SS - Return the steady state of the model (computed analytically)
%
% usage:
% 
% [ss, param] = model_ss(param)


function [ss,param] = model_ss(param)

%Parameters from param object
bet  = param.bet;  %Never call anything beta...it's a matlab function
gam  = param.gam;  %Average gross growth rate of TFP
chi  = param.chi;  %Disutility of labor
del  = param.del;  %Depreciation Rate
alph = param.alph; %Capital Share


%Use closed form expressions for the ss values.
r = 1/(bet*gam^-1)-1+del;
kh = (r/alph)^(1/(alph-1));
w = (1-alph)*(kh)^alph*gam;
c = w/chi;
ck = kh^(alph-1)-(gam-1+del);
k = ck^-1*c;
i = (gam-1+del)*k;
h = kh^-1*k/gam;

%Put the ss values in a vector consistent with Y and X vectors in model.m
yy  = [c h w r i];
xx  = [gam k];
ss  = [yy xx];
