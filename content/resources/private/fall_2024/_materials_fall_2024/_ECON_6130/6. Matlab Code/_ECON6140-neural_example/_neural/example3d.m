%% EXAMPLE: Shows an example of using a neural network to approximate a non-linear function. 


%Target function is known in this case
f = @(w,x,y) 3+ 10*log(w) + x.^2 - 2*y.^3 ;

%Evaluate the true function
wwgrid = linspace( .001,4,20);
xxgrid = linspace(-3,3,20);
yygrid = linspace(-3,3,20);
[ww,xx,yy] = ndgrid(wwgrid,xxgrid,yygrid);
zz = f(ww,xx,yy);

%Plot the true function
f1 = figure;
surf(squeeze(xx(3,:,:)),squeeze(yy(3,:,:)),squeeze(zz(3,:,:)));
hold on
surf(squeeze(xx(15,:,:)),squeeze(yy(15,:,:)),squeeze(zz(15,:,:)));


%Sample the true function with lots of noise
T     = 50000;
chunk = 100;   %Not currently used
rng(0);
wsamp = .001 + rand(T,1)*4;
xsamp = randn(T,1);
ysamp = randn(T,1);
zsamp = f(wsamp,xsamp, ysamp) + .1*randn(T,1);

%Parameters of NN
nx     = 3;   %Number of 'states'
ny     = 1;   %Number of output variables
nh     = [nx,10,ny];   %Size of the layers of the NN
nlayer = length(nh);
%a = {@(x) 1./(1+exp(x)),  @(x) x };  %Activation functions
a = {@(x)log(1+exp(x)),  @(x)x };  %Activation functions

%Count the number of parameters in the NN
nparam = sum(nh(2:end)) + cprod(nh); 
coeff0 = randn(nparam,1);

%Initalize the parameters of the NN
bias   = cell(1,nlayer-1); weights =cell(1,nlayer-1);
ctr_start = 1;
for ii = 1:nlayer-1
    bias{ii}    = zeros(nh(ii+1),1);
    weights{ii} = zeros(nh(ii+1),nh(ii));

    ctr_end = ctr_start+nh(ii+1)-1;
    bias{ii}(:) = coeff0(ctr_start:ctr_end); 
    
    ctr_start = ctr_end+1;
    ctr_end   = ctr_start + nh(ii)*nh(ii+1)-1;
    weights{ii}(:) = coeff0(ctr_start:ctr_end);

    ctr_start = ctr_end+1;
end

%Evaluate once just to test it;
xx = [wsamp';xsamp';ysamp'];
tic
ztest = nn_eval(xx,nh,bias,weights,a);
parfor tt = 1:5000
    ztest = nn_eval(xx,nh,bias,weights,a);
end
toc

work1 = zeros(size(xx));
work2 = zeros(nh(2),size(xx,2));
tic
ztest2 = nn_eval_mex(xx,bias{1},weights{1}',bias{2},weights{2},[0 0 0 1 1 1]',[0,1],work1,work2);
parfor tt = 1:5000
ztest2 = nn_eval_mex(xx,bias{1},weights{1}',bias{2},weights{2},[0 0 0 1 1 1]',[0,1],work1,work2);
end
toc
max(abs(ztest-ztest2))
return
resid_nn(coeff0,wsamp,xsamp,ysamp,zsamp,nh,a);



% fitting step, get parameters
obj = @(coef) resid_nn(coef,wsamp,xsamp,ysamp,zsamp,nh,a);
options = optimoptions('lsqnonlin'); options.Display = 'iter'; options.MaxFunctionEvaluations = 3e5; options.MaxIterations = 3e5;
coeffs_opt = lsqnonlin(obj,coeff0,[],[],[],[],[],[],[],options);

[~,bias1,weights1] = obj(coeffs_opt);

%Evaluate on the grid and show accuracy.
zz_test = reshape(nn_eval([ww(:)'; xx(:)';yy(:)'],nh,bias1,weights1,a),[20,20,20]);

figure(f1);
surf(squeeze(xx(3,:,:)),squeeze(yy(3,:,:)),squeeze(zz_test(3,:,:)));
hold on
surf(squeeze(xx(15,:,:)),squeeze(yy(15,:,:)),squeeze(zz_test(15,:,:)));



disp(['MSE: ' num2str(mean((zz(:)-zz_test(:)).^2))]);

return
% ************************************************************************     
% RESID_NN: Compute the loss when trying to match the data zsamp
% ************************************************************************  
function [out,bias,weights] = resid_nn(coeff0,wsamp,xsamp,ysamp,zsamp,nh,a)
nlayer = length(nh);
bias   = cell(1,nlayer-1); weights =cell(1,nlayer-1);
ctr_start = 1;
for ii = 1:nlayer-1
    bias{ii}    = zeros(nh(ii+1),1);
    weights{ii} = zeros(nh(ii+1),nh(ii));

    ctr_end = ctr_start+nh(ii+1)-1;
    bias{ii}(:) = coeff0(ctr_start:ctr_end); 
    
    ctr_start = ctr_end+1;
    ctr_end   = ctr_start + nh(ii)*nh(ii+1)-1;
    weights{ii}(:) = coeff0(ctr_start:ctr_end);

    ctr_start = ctr_end+1;
end


out = zsamp(:)'-nn_eval([wsamp';xsamp';ysamp'],nh,bias,weights,a);

out = out(:);



end