%% EXAMPLE2D: 
% Shows an example of using a neural network to approximate a non-linear 
% function with two input arguments. 
%
% The fit is optimized using lsqnonlin from matlab. (No machine learning!)
% 
% Output figures show the quality of the approximation.
%
% Ryan Chahrour
% Cornell University, December 2024
addpath("poly2D/")

% Target function is known in this case
%f1 = @(x,y) (3 + 4*x.^2 - 2*y.^3 + .03*(x.^2).*(1.*y).^4)*1/10 ;

f1 = @(x,y) .0*sin(x.^2 + y.^2)  +10*(x.^2 - y.^2) .* exp(-.4*(x.^2 + y.^2));


% Evaluate the true functions
xxgrid = linspace(-3,3);
yygrid = linspace(-3,3);
[xx,yy] = ndgrid(xxgrid,yygrid);
zz1 = f1(xx,yy);

% Sample the true function, but add lots of noise
T     = 1000;
chunk = 100;   %Not currently used
rng(0);
xsamp = 1*randn(T,1);
ysamp = 1*randn(T,1);
zsamp = f1(xsamp, ysamp) + .4*randn(T,1);


MN = 5
P = polyFit2D(zsamp,xsamp,ysamp,MN,MN);


% Scatter the sample points, alongside the true function
figure; scatter3(xsamp,ysamp,zsamp,'marker','.', 'MarkerEdgeColor','k'); hold on; surf(xx,yy,zz1);



% Parameters of NN
nx     = 2;   %Number of 'states'
ny     = 1;   %Number of output variables
nh     = [nx,7,ny];   %Size of the layers of the NN
nlayer = length(nh);
a = {@(x) 1./(1+exp(x)), @(x) x };  %Activation functions

% Count the number of parameters in the NN
nparam = sum(nh(2:end)) + cprod(nh); 
coeff0 = randn(nparam,1);

% Initalize the parameters of the NN
[bias,weights] = nn_pack(coeff0,nh);

% Evaluate once just to test it;
ztest = nn_eval([xsamp';ysamp'],nh,bias,weights,a);
resid_nn(coeff0,xsamp,ysamp,zsamp,nh,a);

% Fitting step, get parameters
obj = @(coef) resid_nn(coef,xsamp,ysamp,zsamp,nh,a);
options = optimoptions('lsqnonlin'); options.Display = 'iter'; options.MaxFunctionEvaluations = 3e5; options.MaxIterations = 1000;
coeffs_opt = lsqnonlin(obj,coeff0,[],[],[],[],[],[],[],options);

[~,bias1,weights1] = obj(coeffs_opt);

% Evaluate on the grid and show accuracy.
zz_test = reshape(nn_eval([xx(:)';yy(:)'],nh,bias1,weights1,a),[100,100]);
zz_poly = reshape(polyVal2D(P,xx(:)',yy(:)',MN,MN),[100,100]);

disp(['MSE: ' num2str(mean((zz1(:)-zz_test(:)).^2))]);

%%
figure
surf(xx,yy,zz1, 'facecolor', 'flat');
hold on
surf(xx,yy,zz_test);


%% slices figure
figure
subplot(2,2,1);
plot(xx(:,50),zz1(:,50)); hold on;
plot(xx(:,50),zz_test(:,50));
plot(xx(:,50),zz_poly(:,50));
xlabel('x (for middle fixed y)'); ylabel('z')

subplot(2,2,2);
plot(xx(:,90),zz1(:,90)); hold on;
plot(xx(:,90),zz_test(:,90));
plot(xx(:,90),zz_poly(:,90));
xlabel('x (for high fixed y)'); ylabel('z')

subplot(2,2,3);
plot(yy(50,:),zz1(50,:)); hold on;
plot(yy(50,:),zz_test(50,:));
plot(yy(50,:),zz_poly(50,:));
xlabel('y (for middle fixed x)'); ylabel('z')

subplot(2,2,4);
plot(yy(90,:),zz1(90,:)); hold on;
plot(yy(90,:),zz_test(90,:));
plot(yy(90,:),zz_poly(90,:));
xlabel('y (for high fixed x)'); ylabel('z')

legend('true','approximated via nn', 'approximated via poly')


return
% ************************************************************************     
% RESID_NN: Compute the loss when trying to match the data zsamp
% ************************************************************************  
function [out,bias,weights] = resid_nn(coeff0,xsamp,ysamp,zsamp,nh,a)

%Put in form for nn_eval
[bias,weights] = nn_pack(coeff0,nh);

%Compute residuals
out = zsamp(:)'-nn_eval([xsamp';ysamp'],nh,bias,weights,a);


%Put into vector
out = out(:);

end