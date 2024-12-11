% Solve for the linear model
% (code from previous pset)

clear;
format long;
tic;

% Add helper functions
addpath('/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Matlab/pset8_helper_functions')

% Load parameters
param = pset8_parameters;

bet = param.bet;
sig = param.sig;
alpha = param.alpha;
deltak = param.deltak;
deltan = param.deltan;
phin = param.phin;
chi = param.chi;
eps = param.eps;
rho = param.rho;
siga = param.siga;

% Solve the linear model
pset7_linear_model;
rehash;
pval  = struct2array(param);

[fy,fx,fyp,fxp,ftest,yxss] = pset7_model_df(pval');
[gx,hx] = gx_hx_alt(fy,fx,fyp,fxp);
eta = [0 ; 1];
disp('gx:');
disp(gx);
disp('hx:');
disp(hx);
disp('yxss:');
disp(yxss);

% Put parameter value in memory
passign(param);

% Steady state values:
abar = yxss(a_idx);
kbar = yxss(k_idx);
cbar = yxss(c_idx);
nbar = yxss(n_idx);
vbar = yxss(val_idx);

% Set grid of shocks
na = 7;
stda = sqrt(siga^2/(1-rho^2));
disp('stda:');
disp(stda);

agrid = exp(linspace(-2*stda,2*stda,na));
[~, epsi, pw] = GH_Quadrature(3,1,1);
egrid = epsi .* siga;

disp('egrid^2:');
disp(egrid'.^2 * pw);

% Create grid for potential realizations of next period's shock
aprime = exp(rho * log(agrid)) + egrid;
disp('aprime:');
disp(aprime);

% Capital grid
nk = 7;
kgrid = linspace(0.9*kbar, 1.1*kbar, nk);

% Labor grid
nn = 21;
ngrid = linspace(0.8*nbar, 1.2*nbar, nn);

% Combination grid
[aagr, kkrg, nngr] = ndgrid(agrid, kgrid, ngrid);
aagr = aagr(:)';
kkrg = kkrg(:)';
nngr = nngr(:)';

state_grid = [aagr; kkrg; nngr];

% Initial policy function guesses
kinit = kbar + 1 * hx(2,:) * [[aagr - abar]; [kkrg - kbar]; [nngr - nbar]];
ninit = nbar + 1 * gx(n_idx,:) * [[aagr - abar]; [kkrg - kbar]; [nngr - nbar]];

kinit = reshape(kinit, [nk, na, nn]);
ninit = reshape(ninit, [nn, na, nk]);

% For residual function
allgrid = {agrid, kgrid, ngrid};

% Initial residual:
resid0 = pset8_residual(kinit(:)', ninit(:)', state_grid, allgrid, aprime, pw, param);
disp('Initial residual:');
disp(sum(abs(resid0(:))));


% Solve for policy functions using projection method
ns = size(state_grid,2);
obj = @(x) pset8_residual(x(1:ns),x(ns+1:2*ns),state_grid,allgrid,aprime,pw,param);
options         = optimoptions('fsolve');
options.Display = 'iter';

xout = fsolve(obj,[kinit(:)',ninit(:)'],options);

% Reshape the output to get the final policy functions
kpol = reshape(xout(1:ns), [na, nk, nn]);
npol = reshape(xout(ns+1:end), [na, nk, nn]);

% Display the value of the final employment policy function (npol) at the lowest levels of K, A, and N
disp('Final employment policy function (npol) at the lowest levels of K, A, and N:');
disp(npol(1, 1, 1));

% Linear policy functions
kinitpol = reshape(kinit,[na,nk,nn]);
ninitpol = reshape(ninit,[na,nk,nn]);

% Define colors
calm_blue = [0.2, 0.6, 0.8];
calm_green = [0.2, 0.8, 0.2];

% Fix A_t and N_{t-1} at their steady state values
a_fixed_idx = find(agrid == abar, 1);
n_fixed_idx = find(ngrid == nbar, 1);

% Get policy functions at steady state
npol_ss = npol(a_fixed_idx, :, n_fixed_idx);
kpol_ss = kpol(a_fixed_idx, :, n_fixed_idx);
ninitpol_ss = ninitpol(a_fixed_idx, :, n_fixed_idx);
kinitpol_ss = kinitpol(a_fixed_idx, :, n_fixed_idx);

figure;
subplot(1,2,1);
plot(kgrid, npol_ss, 'linewidth', 2, 'Color', calm_green); 
ylabel('N'); xlabel('K'); title('N policy with A_t and N_{t-1} at steady state');
hold on;
plot(kgrid, ninitpol_ss, 'LineWidth', 2, 'Color', calm_blue);

subplot(1,2,2);
plot(kgrid, kpol_ss, 'linewidth', 2, 'Color', calm_green); 
ylabel('K'); xlabel('K'); title('K policy with A_t and N_{t-1} at steady state');
hold on;
plot(kgrid, kinitpol_ss, 'LineWidth', 2, 'Color', calm_blue);

legend('Non-linear policy', 'Linear Policy');

saveas(gcf, '/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Matlab/pset8_policy_functions_steady_state.png');


% Simulate over 5000 periods using projection solutions:
% Initialize the Markov chain for the TFP shocks
% Get markov transition matrix
na = 7;
[~, theta, ~] = AR1_rouwen(na,rho,0,siga);
mc = dtmc(theta);
x = simulate(mc, 5000);

% Initialize capital and labor at their steady state values
ks = kbar;
ns = nbar;

% Reshape policy functions
npol = reshape(npol, na, nk, nn);
kpol = reshape(kpol, na, nk, nn);

% Initialize a matrix to store simulation results
vect = zeros(5000, 4);

% Simulate the economy over 5000 periods
for u = 1:5000
    % Find the indices for the current state
    a_idx = x(u);
    k_idx = find(kgrid == ks, 1);
    n_idx = find(ngrid == ns, 1);
    
    % Ensure indices are within bounds
    if isempty(k_idx)
        [~, k_idx] = min(abs(kgrid - ks));
    end
    if isempty(n_idx)
        [~, n_idx] = min(abs(ngrid - ns));
    end

    % Get the policy functions for the current state
    nc = npol(a_idx, k_idx, n_idx);
    kc = kpol(a_idx, k_idx, n_idx);

    % Calculate economic variables
    y = ks^alpha * nc^(1-alpha);
    i = kc - (1-deltak) * ks;
    v = ((nc - (1-deltan) * ns) / chi)^(1/eps);
    c = y - i - phin * v;

    % Store the results
    vect(u, :) = [y, c, i, nc];

    % Update state variables for the next period
    ns = nc;
    ks = kc;
end

% Take the logarithm of the results
lvect = log(vect);

% Standard deviations projection model

disp("Standard deviations projection model:");
disp(['Y: ', num2str(std(lvect(:,1)))]);
disp(['C: ', num2str(std(lvect(:,2)))]);
disp(['I: ', num2str(std(lvect(:,3)))]);
disp(['N: ', num2str(std(lvect(:,4)))]);









toc;