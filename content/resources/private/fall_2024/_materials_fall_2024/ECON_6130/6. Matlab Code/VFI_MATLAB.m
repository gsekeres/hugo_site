%
clc; %clears the command window
clear all; %clears variables
close all; %close all figures
format compact %Set the output format to the short engineering format with compact line spacing

% Time recording 
tic %tic works with the toc function to measure elapsed time, the tic function records the current time

%%
% Parameters setting
alpha = 0.25;  % share of capital from total output
bbeta  = 0.8;   % discount factor
its   = 1;     % Initialize the number of iterations for value function iteration
diff  = 1;     % Initial difference between the old and new value function
tol   = 1e-6;  % Tolerance level to stop the iteration (controls the accuracy of the solution)
s     = 2;     % Utility function curvature (reflects risk aversion in utility calculation)


u = @(c) (c>0).*(1/(1-s)).*(c.^(1-s)-1) +(c<=0).*(-1e18); % utility function with Inada!
%(c>0) indicates which values are greater than zero. 
% For example: A = [-3 -1 0 9 4 3 2]; The output of the command b = (A>0) is: b = [0 0 0 1 1 1 1]

kss = (alpha*bbeta)^(1/(1-alpha));% steady state capital stock

nk = 100;                          % number of data points in the the capital grid
kmin = 0.25*kss;                    % minimum value in the capital grid ... 75% lower than the steady state
kmax = 1.75*kss;                    % maximum value in the capital grid ... 75% more than the steady state
kgrid = linspace(kmin,kmax,nk);     % capital grid
%y = linspace(x1,x2,n) generates n points. The spacing between the points is (x2-x1)/(n-1).
val_fun = zeros(1,nk);              % initial value functions
pol_fun_idx = zeros(1,nk);          % indexes for the policy function

%%
%Value Function Iteration
while diff>tol
    for i=1:length(kgrid)
        c = (kgrid(i)^alpha)-kgrid; %We use scalar (kgrid(i)^alpha) minus vector kgrid to get the result of c corresponding to every element of k' on the grid. 
        % Note that in MATLAB, if we subtract scalar from array, the scalar is subtracted from each entry of A.
        [val_new(i), pol_fun_idx(i)] = max(u(c)+bbeta*val_fun); % Bellman equation
        %[M,I] = max(A)  returns the index into the operating dimension that corresponds to the maximum value of A
    end
    diff= max(abs((val_new-val_fun)));
    %Y = abs(X) returns the absolute value of each element in array X.
    %M = max(A) returns the maximum elements of an array.
    val_fun=val_new;
    its = its+1;
end

pol_fun = kgrid(pol_fun_idx);   % This collects the points on the grid that resulted in the maximal value function
cons = (kgrid.^alpha)-pol_fun;

%% Plots
% Plotting the value function and the policy function
figure(1)
plot(kgrid,pol_fun,'linewidth',1.8); title('Policy Function (k_{t+1})'); ...
    xlabel('k_t'); ylabel('k_{t+1}'); grid on ; hold on; plot([0 kmax],[0 kmax]); ...
    xlim([0 kmax]); saveas(gcf,'pol_fun_k.png')
%plot(X,Y) plots a 2-D line plot of the data in Y versus the corresponding values in X.

toc % The toc function uses the recorded value to calculate the elapsed time.
