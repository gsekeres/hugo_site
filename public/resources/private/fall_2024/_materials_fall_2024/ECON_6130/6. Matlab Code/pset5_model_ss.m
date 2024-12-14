function [ss, param] = pset5_model_ss(param)
%Parameters from param object
bet  = param.bet;
alpha = param.alpha;
deltak = param.deltak;
deltan = param.deltan;
phin = param.phin;
chi = param.chi;
eps = param.eps;

%Use closed form expressions for the ss values.
kn = ((1/bet - 1 + deltak) / alpha)^(1 / (alpha - 1));
v = (((eps*chi) / phin) * (1 - alpha) / (1 - bet * (1 - deltan)) * kn ^ alpha)^(1 / (1 - eps));
n = chi * v ^ eps / deltan;
k = kn * n;
y = k^alpha * n^(1-alpha);
i = deltak * k;
c = y - i - phin * v;


%Put the ss values in a vector
xx = [1 k n];
yy = [y c i n v];
ss = [xx yy];
end
