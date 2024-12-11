%**************************************************************************
% SOLVE_PROJECTION: Example code for ECON6140. Solves the (stationary) neoclassical
% model using linear basis functions for functional approximation and Gaussian-Hermit quadrature to
% compute expections.
%
% Ryan Chahrour
% Cornell University
% December 2024
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
nbar = yxss(n_idx);
vacbar = yxss(vac_idx);
vbar = yxss(val_idx);

siga = .01;

scl = 1;

%Agrid/Egrid 
na = 7;
stda  = sqrt(siga^2/(1-rho^2)); %Standard dev of log(a)
agrid = exp(linspace(-2*stda,2*stda,na));  %State values for log(a)
[~,epse, pw] = GH_Quadrature(3,1,1);
egrid = epse.*siga;

%Kgrid - in levels
nk    = 7;
kgrid = linspace(kbar*(1-scl*.1),kbar*(1+scl*.1),nk);

%Ngrid - in levels
nn    = 21;
ngrid = linspace(nbar*(1-scl*.2),nbar*(1+scl*.2),nn);

allgrid = {agrid,kgrid,ngrid};

%A/K/N combos as initial states
[aagr,kkgr,nngr] = ndgrid(agrid,kgrid,ngrid);
aagr = aagr(:)' ;
kkgr = kkgr(:)';
nngr = nngr(:)';
state_grid = [aagr;kkgr;nngr];

ns = size(state_grid,2);
aprime = exp(rho*log(aagr) + egrid);  %This is all possible value for a(t+1) starting from grid over a(t)

%Initial policy functions for K(t+1), N(t)
kinit = kbar + 1*hx(2,:)*[aagr-abar;kkgr-kbar;nngr-nbar];
ninit = nbar + 1*hx(3,:)*[aagr-abar;kkgr-kbar;nngr-nbar];

kinit = reshape(kinit,[na,nk,nn]);
ninit = reshape(ninit,[na,nk,nn]);

%**************************************************************************
% MAIN SOLUTION
%**************************************************************************

    
resid0 = residual(kinit(:)',ninit(:)',state_grid,allgrid,aprime,pw,param);

sum(abs(resid0(:)))

obj = @(x) residual(x(1:ns),x(ns+1:2*ns),state_grid,allgrid,aprime,pw,param);

options         = optimoptions('fsolve');
options.Display = 'iter';

xout = fsolve(obj,[kinit(:)',ninit(:)'],options);

kpol = reshape(xout(1:ns),[na,nk,nn]);
npol = reshape(xout(ns+1:end),[na,nk,nn]);

%**************************************************************************
% SIMULATION
%**************************************************************************
Xsim = zeros(3,5000);
Xsim(:,1) = [1,kbar,nbar];
rng(0);
for jj = 1:(5000-1)
   Xsim(1,jj+1) = exp(rho*log(Xsim(1,jj)) + siga*randn(1,1)); 
end

%simulate the state evolution
for jj = 1:5000-1
    Xsim(2,jj+1) = ndim_simplex_eval(allgrid,Xsim(:,jj),kpol(:));
    Xsim(3,jj+1) = ndim_simplex_eval(allgrid,Xsim(:,jj),npol(:));
end


%%

figure;
subplot(3,2,1);
plot(kgrid,npol(1,:,ceil(nn/2)), 'linewidth',2); ylabel('low A'); xlabel('K'); title('N policy')
hold on
plot(kgrid, ninit(1,:,ceil(nn/2)), '--','linewidth',2);
subplot(3,2,2)
plot(kgrid,kpol(1,:,ceil(nn/2)),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(1,:,ceil(nn/2)), '--','linewidth',2);

subplot(3,2,3);
plot(kgrid,npol(4,:,ceil(nn/2)), 'linewidth',2); ylabel('med A'); xlabel('K'); title('N policy')
hold on
plot(kgrid, ninit(4,:,ceil(nn/2)), '--','linewidth',2);
subplot(3,2,4)
plot(kgrid,kpol(4,:,ceil(nn/2)),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(4,:,ceil(nn/2)), '--','linewidth',2);

subplot(3,2,5);
plot(kgrid,npol(na,:,ceil(nn/2)), 'linewidth',2); ylabel('high A'); xlabel('K'); title('N policy')
hold on
plot(kgrid, ninit(na,:,ceil(nn/2)), '--','linewidth',2);
subplot(3,2,6)
plot(kgrid,kpol(na,:,ceil(nn/2)),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(na,:,ceil(nn/2)), '--','linewidth',2);

legend('Non-linear policy','Linear Policy');



%%
figure;
subplot(3,2,1);
plot(ngrid,squeeze(npol(1,ceil(nk/2),:)), 'linewidth',2); ylabel('low A'); xlabel('N'); title('N policy')
hold on
plot(ngrid, squeeze(ninit(1,ceil(nk/2),:)), '--','linewidth',2);
subplot(3,2,2)
plot(ngrid,squeeze(kpol(1,ceil(nk/2),:)),'linewidth',2); title('K policy')
hold on
plot(ngrid, squeeze(kinit(1,ceil(nk/2),:)), '--','linewidth',2);


subplot(3,2,3);
plot(ngrid,squeeze(npol(4,ceil(nk/2),:)), 'linewidth',2); ylabel('med A'); xlabel('N'); title('N policy')
hold on
plot(ngrid, squeeze(ninit(4,ceil(nk/2),:)), '--','linewidth',2);
subplot(3,2,4)
plot(ngrid,squeeze(kpol(4,ceil(nk/2),:)),'linewidth',2); title('K policy')
hold on
plot(ngrid, squeeze(kinit(4,ceil(nk/2),:)), '--','linewidth',2);


subplot(3,2,5);
plot(ngrid,squeeze(npol(7,ceil(nk/2),:)), 'linewidth',2); ylabel('high A'); xlabel('N'); title('N policy')
hold on
plot(ngrid, squeeze(ninit(7,ceil(nk/2),:)), '--','linewidth',2);
subplot(3,2,6)
plot(ngrid,squeeze(kpol(7,ceil(nk/2),:)),'linewidth',2); title('K policy')
hold on
plot(ngrid, squeeze(kinit(7,ceil(nk/2),:)), '--','linewidth',2);

legend('Non-linear policy','Linear Policy');





