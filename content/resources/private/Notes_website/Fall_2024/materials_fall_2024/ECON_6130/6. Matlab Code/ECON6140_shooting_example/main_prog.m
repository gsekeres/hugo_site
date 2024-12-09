%**************************************************************************
% MAIN_PROG: Example code for ECON6140. Solves the (stationary) neoclassical
% model using a shooting/perfect foresight approach.
%
% Ryan Chahrour
% Cornell University
% March 2024
%**************************************************************************
addpath('helper_functions')

param = parameters;

passign(param);  %Unpacks the param object

[Xss,Yss] = model_ss(param);
ss        = [Xss,Yss];

%Compute the first-order coefficiencients of the model
[fyn, fxn, fypn, fxpn, fn, log_var] = model(param);
ss(log_var) = log(ss(log_var));

%Compute the transition and policy functions, using code by
%Stephanie Schmitt-Grohé and Martín Uribe (and available on their website.)
[gx,hx]=gx_hx_alt(fyn,fxn,fypn,fxpn);

%Shock hits GAM, which is the first state
eta = [siga;0];

%Eigenvalues of hx
disp('Computing eigenvalues of hx');
disp(eig(hx))

%Generate inpulse responses
X = zeros(size(hx,1),500);
X(:,1) = eta;
for ii = 1:499
    X(:,ii+1) = hx*X(:,ii);
end
Y = gx*X;

XY = [X;Y];
var_names = {'A', 'K', 'C','H', 'W', 'R', 'I','V'};
f = figure;
for ii = 1:8
    s = subplot(4,2,ii); hold on
    p = plot(0:20,XY(ii,1:21));
    title(var_names{ii});
end

%Stack X(t+1) with Y(t) in log deviations, as initial values from linearized model
XYv  = [X(:,2:end), zeros(2,1); Y(:,1:end)];

disp('initial residual')
resid0 = resid(XYv,ss,param,log_var);
disp(num2str(sum(abs(resid0(:)))))

%Solve the equations
options = optimoptions('fsolve');
options.Display = 'iter';
obj = @(x) resid(x,ss,param,log_var);

XpYshoot = fsolve(obj,XYv,options);
XYshoot = [X(:,1),XpYshoot(1:2,1:end-1); XpYshoot(3:end,:)];

figure(f);
for ii = 1:8
    s = subplot(4,2,ii); hold on
    p = plot(0:20,XYshoot(ii,1:21), '-.x');
end

legend('Linear', 'Non-linear')
