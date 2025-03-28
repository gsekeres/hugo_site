clear;
close all;
tic;

% Set the parameters
param = pset6_parameters;

param.siga = 0.1;

% Find steady state values
[ss, ~] = pset5_model_ss(param);

% Find linearized policy functions
[fyn, fxn, fypn, fxpn, ~, log_var] = pset6_model(param);
[gx, hx] = pset5_gx_hx(fyn, fxn, fypn, fxpn);
ss(log_var) = log(ss(log_var));

disp('hx')
disp(hx)
disp('gx')
disp(gx)

% Number of periods
N = 500;

% Initialize shock (1% increase in TFP)
eta = zeros(3,3);
eta(1,1) = 0.1;

% Generate impulse responses for initial guess
X = zeros(3, N);
X(:,1) = eta*[1; 0; 0];
for i = 1:N-1
    X(:,i+1) = hx*X(:,i);
end
Y = gx*X;

XY = [X;Y];
var_names = {'A_{t}', 'K_{t}', 'N_{t-1}','Y_{t}', 'C_{t}', 'I_{t}', 'N_{t}','V_{t}'};
f = figure;
for ii = 1:8
    s = subplot(4,2,ii); hold on
    p = plot(0:50,XY(ii,1:51));
    title(var_names{ii});
end

% Stack X(t+1) with Y(t) in log deviations
XYv = [X(:,2:end), zeros(3,1); Y(:,1:end)];

disp('initial residual')
resid0 = pset6_residual(XYv,ss,param, log_var);
disp(num2str(sum(abs(resid0(:)))))

%Solve the equations
options = optimoptions('fsolve');
options.Display = 'iter';
obj = @(x) pset6_residual(x,ss,param,log_var);

XpYshoot = fsolve(obj,XYv,options);
XYshoot = [X(:,1),XpYshoot(1:3,1:end-1); XpYshoot(4:end,:)];

figure(f);
for ii = 1:8
    s = subplot(4,2,ii); hold on
    p = plot(0:50,XYshoot(ii,1:51), '-.x');
end

legend('Linear', 'Non-linear')
saveas(f, '/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Matlab/pset6_shoot_10.png')

toc;