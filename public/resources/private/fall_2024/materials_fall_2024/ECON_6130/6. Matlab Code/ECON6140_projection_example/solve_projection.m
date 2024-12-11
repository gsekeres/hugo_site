%**************************************************************************
% SOLVE_PROJETION: Example code for ECON6140. Solves the (stationary) neoclassical
% model using projection approach to approximate the policy functions for
% captial and labor.
%
% Ryan Chahrour
% Cornell University
% April 2024
%**************************************************************************
addpath('helper_functions')

%% Solve linear version of model
linear_model
rehash
param = parameters;
pval  = struct2array(param);

[fy,fx,fyp,fxp,ftest,yxss] = model_df(pval');
[gx,hx] = gx_hx_alt(fy,fx,fyp,fxp);
eta = [0;1];

%% The value function iteration

%put parameter value in memory
passign(param);

%steady-state stuff
abar = yxss(a_idx);
kbar = yxss(k_idx);
cbar = yxss(c_idx);
hbar = yxss(h_idx);

%Toggle with STD of productivity innovation
siga = .02;

scl = 2;  %Set's the scale of the grid in K

%Agrid/Egrid 
na = 7;
stda  = sqrt(siga^2/(1-rho^2)); %Standard dev of log(a)
agrid = exp(linspace(-2*stda,2*stda,na));  %State values for log(a)
[~,epse, pw] = GH_Quadrature(3,1,1);
egrid = epse.*siga;


%Kgrid - in levels
nk    = 21;
kgrid = linspace(kbar*(1-scl*.2),kbar*(1+scl*.2),nk);


allgrid = {agrid,kgrid};

%A/K combos as initial states
[aagr,kkgr] = ndgrid(agrid,kgrid);
aagr = aagr(:)' ;
kkgr = kkgr(:)';
state_grid = [aagr;kkgr];


ns = size(state_grid,2);
aprime = exp(rho*log(aagr) + egrid);  %This is all possible value for a(t+1) starting from grid over a(t)

%Initial policy functions for K(t+1), N(t)
kinit = kbar + 1*hx(2,:)*[aagr-abar;kkgr-kbar];
hinit = hbar + 1*gx(2,:)*[aagr-abar;kkgr-kbar];

kinit = reshape(kinit,[na,nk]);
hinit = reshape(hinit,[na,nk]);

%**************************************************************************
% MAIN SOLUTION
%**************************************************************************

resid0 = residual(kinit(:)',hinit(:)',state_grid,allgrid,aprime,pw,param);

obj = @(x) residual(x(1:ns),x(ns+1:2*ns),state_grid,allgrid,aprime,pw,param);

options         = optimoptions('fsolve');
options.Display = 'iter';

xout = fsolve(obj,[kinit(:)',hinit(:)'],options);

kpol = reshape(xout(1:ns),[na,nk]);
hpol = reshape(xout(ns+1:end),[na,nk]);


%%

figure;
subplot(3,2,1);
plot(kgrid,hpol(1,:), 'linewidth',2); ylabel('low A'); xlabel('K'); title('H policy')
hold on
plot(kgrid, hinit(1,:), '--','linewidth',2);
subplot(3,2,2)
plot(kgrid,kpol(1,:),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(1,:), '--','linewidth',2);

subplot(3,2,3);
plot(kgrid,hpol(4,:), 'linewidth',2); ylabel('med A'); xlabel('K'); title('H policy')
hold on
plot(kgrid, hinit(4,:), '--','linewidth',2);
subplot(3,2,4)
plot(kgrid,kpol(4,:),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(4,:), '--','linewidth',2);

subplot(3,2,5);
plot(kgrid,hpol(na,:), 'linewidth',2); ylabel('high A'); xlabel('K'); title('H policy')
hold on
plot(kgrid, hinit(na,:), '--','linewidth',2);
subplot(3,2,6)
plot(kgrid,kpol(na,:),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(na,:), '--','linewidth',2);

legend('Non-linear policy','Linear Policy');







