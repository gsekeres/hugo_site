clear

tic

%Load Parameters
param = pset5_parameters;

disp('ss param:')
disp(pset5_model_ss(param))

%Compute the first-order coefficiencients of the model
[fyn, fxn, fypn, fxpn, fn] = pset5_model(param);

[gx,hx]= pset5_gx_hx(fyn,fxn,fypn,fxpn);

disp('gx:')
disp(gx)
disp('hx:')
disp(hx)

%Initialize shock
eta = zeros(3,3);
eta(1,1) = param.siga;

disp('eta:')
disp(eta)

%Eigenvalues of hx
disp('Computing eigenvalues of hx')
disp(eig(hx))

%Number of periods for shock
T = 20;

%Impulse response functions
IRF_x = zeros(3,T);
IRF_y = zeros(5,T);

for i = 1:T
    IRF_x(:,i) = hx^i * eta * [1 0 0]';
    IRF_y(:,i) = gx * hx^i * eta * [1 0 0]';
end

%Figure of impulse response functions
subplot(4,2,1)
plot(IRF_x(1,:))
title('Technology shock on A_{t}')
subplot(4,2,2)
plot(IRF_x(2,:))
title('Technology shock on K_{t}')
subplot(4,2,3)
plot(IRF_x(3,:))
title('Technology shock on N_{t-1}')
subplot(4,2,4)
plot(IRF_y(1,:))
title('Technology shock on Y_{t}')
subplot(4,2,5)
plot(IRF_y(2,:))
title('Technology shock on C_{t}')
subplot(4,2,6)
plot(IRF_y(3,:))
title('Technology shock on I_{t}')
subplot(4,2,7)
plot(IRF_y(4,:))
title('Technology shock on N_{t}')
subplot(4,2,8)
plot(IRF_y(5,:))
title('Technology shock on V_{t}')

saveas(gcf, '/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Matlab/pset5_tech_shock.png')


%Simulate with random shocks
rng(0);
L = 5000;
epsilon = randn(1,L);
epsilon = [0 epsilon];

simX = zeros(3,L+1);
simY = zeros(5,L+1);
for i = 1:L
    simX(:,i+1) = hx * simX(:,i) + eta * [epsilon(i+1) 0 0]';
    simY(:,i+1) = gx * simX(:,i+1);
end

simYt = simY(1,:);
simC = simY(2,:);
simI = simY(3,:);
simN = simY(4,:);
simV = simY(5,:);

%First five realizations of productivity
disp("First five realizations of productivity:")
disp(simX(1,2:6))

%Standard Deviations
disp("Standard Deviations:")
disp("SD Y: " + std(simYt))
disp("SD C: " + std(simC))
disp("SD I: " + std(simI))
disp("SD N: " + std(simN))


%Autocorrelations
[acf_Y, lags] = autocorr(simYt, 'NumLags', 1);
[acf_C, ~] = autocorr(simC, 'NumLags', 1);
[acf_I, ~] = autocorr(simI, 'NumLags', 1);
[acf_N, ~] = autocorr(simN, 'NumLags', 1);

% Display results (take second value as first is always 1)
disp("Autocorrelations:")
disp("Y: " + num2str(acf_Y(2)))
disp("C: " + num2str(acf_C(2)))
disp("I: " + num2str(acf_I(2)))
disp("N: " + num2str(acf_N(2)))


toc