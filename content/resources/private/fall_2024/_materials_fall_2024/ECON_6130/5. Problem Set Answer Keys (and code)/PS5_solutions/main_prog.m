%**************************************************************
% MAIN_PROG - Solves the neoclassical with labor search
%
% Code by Ryan Chahrour, Cornell University
%**************************************************************

param.bet  = 0.99;
param.sig  = 2.00;
param.alph = 0.30;
param.delk = 0.03;
param.deln = 0.10;
param.phin = 0.50;
param.chi  = 1.00;
param.veps = 0.25;
param.rho  = 0.95;
param.siga = 0.01;

[Xss,Yss] = model_ss(param);

%Compute the first-order coefficiencients of the model
[fyn, fxn, fypn, fxpn, fn] = model(param);

%Compute the transition and policy functions, using code by
%Stephanie Schmitt-Grohé and Martín Uribe (and available on their website.)
[gx,hx]=gx_hx_alt(fyn,fxn,fypn,fxpn);

%Shock hits GAM, which is the first state
eta = [param.siga;0;0];

%Eigenvalues of hx
disp('Computing eigenvalues of hx');
disp(eig(hx))


%Generate inpulse responses
X = zeros(size(hx,1),20);
X(:,1) = eta;
for ii = 1:20
    X(:,ii+1) = hx*X(:,ii);
end
Y = gx*X;

XY = [X;Y];
var_names = {'A', 'K', 'N','Y', 'C', 'I', 'N','V'};
figure;
for ii = 1:8
    s = subplot(4,2,ii);
    p = plot(0:20,XY(ii,:));
    title(var_names{ii});
end

%Generate simluation
rng(0); %See random number generator
dstbc = randn(5000,1);

Xsim = zeros(size(hx,1),5001);
for ii = 1:5000
  Xsim(:,ii+1) = hx*Xsim(:,ii) + eta*dstbc(ii);
end
Ysim = gx*Xsim;

std([Xsim;Ysim]')