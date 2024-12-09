%**************************************************************
% MAIN_PROG - Solves the neoclassical with labor search
%
% Code by Ryan Chahrour, Cornell University
%**************************************************************

param = parameters;

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
X = zeros(size(hx,1),500);
X(:,1) = eta;
for ii = 1:499
    X(:,ii+1) = hx*X(:,ii);
end
Y = gx*X;

%Plot impulse responses in log-deviations from steady-state 
XY = [X;Y];
var_names = {'A', 'K', 'N','Y', 'C', 'I', 'N','V'};
f = figure;
for ii = 1:8
    s = subplot(4,2,ii); hold on
    p = plot(0:20,XY(ii,1:21));
    title(var_names{ii});
end


%Stack X(t+1) with Y(t) in log deviations
XpY = [X(:,2:end), zeros(3,1); Y(:,1:end)];

%Compute the residual function
XYv = exp(XpY+log([Xss(:);Yss(:)]));  %Initial value from linearized model

resid0 = resid(XYv,[Xss,Yss],param);

sum(abs(resid0(:)))

%Solve the equations
options = optimoptions('fsolve');
options.Display = 'iter';
obj = @(x) resid(x,[Xss,Yss],param);

XpYshoot = fsolve(obj,XYv,options);
XpYshoot = log(reshape(XpYshoot,[8,numel(XpYshoot)/8])./[Xss(:);Yss(:)]);
XYshoot  = [X(:,1),XpYshoot(1:3,1:end-1); XpYshoot(4:end,:)]


figure(f);
for ii = 1:8
    s = subplot(4,2,ii); hold on
    p = plot(0:20,XYshoot(ii,1:21), '-.x');
end

legend('Linear', 'Non-linear')