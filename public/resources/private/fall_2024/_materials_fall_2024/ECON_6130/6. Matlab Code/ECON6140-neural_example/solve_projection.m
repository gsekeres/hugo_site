%**************************************************************************
% SOLVE_PROJETION: Example code for ECON6140. Solves the (stationary) neoclassical
% model using neural networks to approximate the policy functions for
% captial and labor over a simulated grid.
%
% Ryan Chahrour
% Cornell University
% December 2024
%**************************************************************************
addpath('helper_functions')
addpath('neural')

%% Solve linear version of model
linear_model
rehash
param = parameters;
pval  = struct2array(param);

[fy,fx,fyp,fxp,ftest,yxss] = model_df(pval');
[gx,hx] = gx_hx_alt(fy,fx,fyp,fxp);
disp(ftest)
nx = size(hx,1);

eta = zeros(nx,1); eta(end) = param.siga;

%steady-state stuff
abar = yxss(a_idx);
kbar = yxss(k_idx);
cbar = yxss(c_idx);
hbar = yxss(h_idx);

rng(0);
[ysim,xsim] = quick_sim(gx,hx,eta,zeros(nx,1),randn(1,5000));

kgrid = xsim(1,:)     + kbar;
agrid = xsim(2,:)     + abar;
egrid = xsim(3:end,:) + log(1);

xbar = [kbar;abar;log(ones(nx-2,1))];


stdz_x.mean = xbar;
stdz_x.std  = std(xsim')';


%% The value function iteration

%put parameter value in memory
passign(param);

%Toggle with STD of productivity innovation
siga = param.siga;


%Shock_grid 
[~,epse, pw] = GH_Quadrature(3,1,1);
eegrid = epse.*siga;

%All points at which we "check" the optimality conditions.
state_grid = [kgrid;agrid;egrid];


%Initial policy functions for K(t+1), H(t)
kinit = kbar + hx(1,:)*[state_grid - xbar];
hinit = hbar + gx(2,:)*[state_grid - xbar];

pol_init = [kinit;hinit];

%Standardize y variables
stdz_y = cell(1,2);
stdz_y{1}.mean = kbar;
stdz_y{1}.std = std(kinit);
stdz_y{2}.mean = hbar;
stdz_y{2}.std = std(hinit);

%Compute all the possible futures
aprime   = hx(2:end,2:end)*(state_grid(2:end,:)-stdz_x.mean(2:end))+stdz_x.mean(2:end);
aprime_p = zeros(nx-1,size(aprime,2)*3);
for ee = 1:nx-2
   aprime_p(ee,:) = vec(repmat_row(aprime(ee,:),3))';
end
aprime_p(nx-1,:) = vec(repmat_row(aprime(end,:),3) + eegrid)';
ns     =   size(state_grid,2);

%**************************************************************************
% INITIAL VALUE FOR NEURAL NET
% - This step is not as easy.  We need to perform a fit to decent initial
% policy functions. 
%**************************************************************************

npol = 2; %Number of policy functions
a = {@(x) 1./(1+exp(x)),  @(x)x };  %Activation functions
%a = {@(x)log(1+exp(x)),  @(x)x };  %Activation functions

np = 1;                   %Number of output variables for each NN
nh = [nx  16 np];

rng(0)
nparam = sum(nh(2:end)) + cprod(nh); 
coeff0 = .01*randn(nparam,npol);

options = optimoptions('lsqnonlin'); options.Display = 'iter'; options.MaxFunctionEvaluations = 3e5; options.MaxIterations = 1000; options.SpecifyObjectiveGradient = false;
coeff_all = zeros(nparam,npol);
bias0     = cell(1,npol);
weights0  = cell(1,npol);

tic
for jj = 1:npol

    %Fitting step
    obj = @(coef) resid_nn(coef,state_grid,pol_init(jj,:),nh,a,stdz_x,stdz_y{jj});
    coeffs_opt = lsqnonlin(obj,coeff0(:,jj),[],[],[],[],[],[],[],options);

    %Store coefficients
    [~,bias0{jj},weights0{jj}] = obj(coeffs_opt);
    coeff_all(:,jj) = coeffs_opt;

end
tout = toc;
disp(['Initial fit took ' num2str(tout) ' seconds.'])


%% **************************************************************************
% MAIN SOLUTION
%**************************************************************************

resid0 = residual(coeff_all,state_grid,aprime_p,pw,param,nh,nparam,a,stdz_x,stdz_y)

sum(resid0(:).^2)


obj = @(x) residual(x,state_grid,aprime_p,pw,param,nh,nparam,a,stdz_x,stdz_y)

options = optimoptions('lsqnonlin'); options.Display = 'iter'; options.MaxFunctionEvaluations = 3e5; options.MaxIterations = 500; options.SpecifyObjectiveGradient = false;

xout = lsqnonlin(obj,coeff_all,[],[],[],[],[],[],[],options);

return

%% Plot results
[bias_k,weights_k] = nn_pack(xout(1:nparam),nh);
[bias_h,weights_h] = nn_pack(xout(nparam+1:end),nh);

na = 7;
stda  = sqrt(siga^2/(1-rho^2)); %Standard dev of log(a)
agrid = exp(linspace(-2*stda,2*stda,na));  %State values for log(a)

xtest         = linspace(kbar-3*stdz_x(1).std(1),kbar+3*stdz_x(1).std(1));
xtest(2,:)    = 0;
xtest(3:nx,:) = 0


k_nonlin = nn_eval(xtest,nh,bias_k,weights_k,a,stdz_x,stdz_y{1});
h_nonlin = nn_eval(xtest,nh,bias_h,weights_h,a,stdz_x,stdz_y{2});
k_lin = hx(1,:)*(xtest-xbar) + kbar;
h_lin = gx(2,:)*(xtest-xbar) + hbar;

figure;

%Middle A
subplot(nx,2,1);
plot(xtest(1,:),h_nonlin(1,:), 'linewidth',2); ylabel('Middle A'); xlabel('K'); title('H policy')
hold on
plot(xtest(1,:), h_lin(1,:), '--','linewidth',2);

subplot(nx,2,2)
plot(xtest(1,:),k_nonlin(1,:),'linewidth',2); title('K policy')
hold on
plot(xtest(1,:), k_lin(1,:), '--','linewidth',2);


%For news of different horizons
cap_list = {'Surprise', 'News 1', 'News 2', 'News 3'}
xtest(1,:) = kbar;
xtestss = xtest;
for jj  = 1:nx-1
    xtest = xtestss
    xtest(1+jj,:) = linspace(-3*siga,3*siga);
    k_nonlin = nn_eval(xtest,nh,bias_k,weights_k,a,stdz_x,stdz_y{1});
    h_nonlin = nn_eval(xtest,nh,bias_h,weights_h,a,stdz_x,stdz_y{2});
    k_lin = hx(1,:)*(xtest-xbar) + kbar;
    h_lin = gx(2,:)*(xtest-xbar) + hbar;

    subplot(nx,2,1+2*jj);
    plot(xtest(1+jj,:),h_nonlin(1,:), 'linewidth',2); xlabel(cap_list{jj}); title('H policy')
    hold on
    plot(xtest(1+jj,:), h_lin(1,:), '--','linewidth',2);

    subplot(nx,2,2+2*jj);
    plot(xtest(1+jj,:),k_nonlin(1,:), 'linewidth',2); xlabel(cap_list{jj}); title('K policy')
    hold on
    plot(xtest(1+jj,:), k_lin(1,:), '--','linewidth',2);

end




%% ************************************************************************
% RESID_NN: Compute the loss when trying to match the data ysamp
% ************************************************************************
function [out,bias,weights] = resid_nn(coeff0,xsamp,ysamp,nh,a,stdz_x,stdz_e)

[bias,weights] = nn_pack(coeff0,nh);

out = ysamp-nn_eval(xsamp,nh,bias,weights,a,stdz_x,stdz_e);
out = out(:);


%mean(nn_eval(xsamp,nh,bias,weights,a,stdz_x,stdz_e))
end