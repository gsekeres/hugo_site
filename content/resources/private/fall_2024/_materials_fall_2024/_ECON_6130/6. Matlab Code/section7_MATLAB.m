%%
clc

clear all
close all

%% Setup of the AR(1) Process
% Simulates Markov chain approximation to AR(1) process, runs value
% function iteration, simulates neoclassical growth model for ECON 6130

% Markov chain approximation
% AR(1) process: y_t+1=Ky_t+e_t, e_t IID normal
% Parameters: K, mean of e_t, long-run variance of y_t, long-run mean of
% y_t, size of sample space
K=0.8; %persistence of the AR(1) process
mean_e=0; %mean of the shock e_t
LRvar_y=.3; %long-run variance of y_t
LRmean_y=0; %long-run mean of y_t
size_space=5; %number of realizations of y_t
% Implied variance of e_t
var_e=(1-K^2)*LRvar_y; %variance of the shock e_t

%% Set the realizations of y_t
% 1-d vector for sample space
sample_space=linspace(LRmean_y-((size_space-1)/2)*sqrt(LRvar_y),...
LRmean_y+((size_space-1)/2)*sqrt(LRvar_y),...
size_space);
% The space: {LRmean_y-2*sqrt(LRvar_y),LRmean_y-sqrt(LRvar_y),LRmean,
% LRmean_y+sqrt(LRvar_y),LRmean_y+2*sqrt(LRvar_y)}

%% Find the transition matrix
% 2-d transition matrix, conditional probabilities found using the method
% of Tauchen (1986)
% midpoints are implicitly defined as sample_space(j)+/- 0.5*sqrt(LRvar_y),
% as the gap between any two adjacent realizations of y_t is equal to sqrt(LRvar_y)
trans=zeros(size_space, size_space);
for i=1:size_space
    for j=1:size_space
        if j==1
        trans(i,j)=normcdf((sample_space(j)-K*sample_space(i)+0.5*sqrt(LRvar_y))...
        /sqrt(var_e));
        elseif j==size_space
        trans(i,j)=1-normcdf((sample_space(j)-K*sample_space(i)-0.5*sqrt(LRvar_y))...
        /sqrt(var_e));
        else
        trans(i,j)=normcdf((sample_space(j)-K*sample_space(i)+0.5*sqrt(LRvar_y))...
        /sqrt(var_e))...
        -normcdf((sample_space(j)-K*sample_space(i)-0.5*sqrt(LRvar_y))...
        /sqrt(var_e));
        end
    end
end

%% Calculate stationary distribution of transition matrix
A=trans'-diag(ones(1,size_space));
A(size_space,:)=ones(1,size_space);
b=zeros(size_space,1);
b(size_space)=1;
stationary=(A\b)';

%% Simulate Markov Chain for T steps, with initial state distributed according 
% to stationary distribution
T=2000;

y_state=zeros(1,T); %the index of the realization of the variable y_t over T periods
y_val=zeros(1,T); %the value of the realization of the variable y_t over T periods
for i=1:T
    num=rand; %random variable drawn from the unifrom distribution defined on the interval [0,1]
    done=0; %a binary variable that determines whether the 'while' loop should be stopped
    j=0; %j is the index of the realization of the variable y_t
    while done==0
        j=j+1;
        if i==1 %the first period
            if j==1
                if num<=stationary(j)
                    done=1;
                end
            elseif sum(stationary(1:j-1))<num &&...
                    num<=sum(stationary(1:j))
                    done=1;
            end
        else % from period 2 to period T
            if j==1
                if num<=trans(y_state(i-1),j)
                    done=1;
                end
            elseif sum(trans(y_state(i-1),1:j-1))<num &&...
                    num<=sum(trans(y_state(i-1),1:j))
                    done=1;
            end
        end
    end
    y_state(i)=j;
    y_val(i)=sample_space(y_state(i));
end

plot(y_val)
title('Markov Chain Simulation, T=2000')
xlabel('Time')
ylabel('y_t')

%% Value function iteration
% Parameter Values
alpha=0.2;
beta=0.8;

% 1-d capital grid
grid_size=100;
grid_max=18;
k_grid=linspace(0,grid_max,grid_size);

% 3-d array for value functons. Entry (1,j,k) evaluates current value function
% at capital level k_grid(j) and income shock sample_space(k). Entry
% (2,j,k) to store next iteration of value function.
% Initialize with value(i,j,k)=0 for all i,j,k.
value=zeros(2,grid_size,size_space);

% Tolerance for value function error
tol=10^(-6);

% Supremum distance between value function 1 and value function 2,
% initialized at 1
sup=1;

% 3-d array for value of objective in iterations. Entry (i,j,k) gives value
% of objective if current-period capital is k_grid(i), current income shock
% is sample_space(j), and next-period capital is k_grid(k)
value_iter=zeros(grid_size,size_space,grid_size);

% Loop to compute value functions iteratively, continue until sup<tol
while sup>=tol
% Rename previous iteration's value function as base value function for
% current iteration
    value(1,:,:)=value(2,:,:);
% Loop over current income shock values in sample_space
    for k=1:size_space
% Loop over current capital values in k_grid
        for i=1:grid_size
% Loop over next-period capital values in k_grid
            for j=1:grid_size
% Check if feasibility is satisfied, capital strictly
% positive (Inada conditions assumed)
                if 0<k_grid(j) && k_grid(j)<=exp(sample_space(k))*k_grid(i)^alpha
% Calculate value of objective with current-period capital
% k_grid(i), next-period capital k_grid(j), and
% current-period shock sample_space(k)
                   value_iter(i,k,j)=log(exp(sample_space(k))*k_grid(i)^alpha...
                    -k_grid(j))+beta*trans(k,:)*squeeze(value(1,j,:));
% Set value to -Inf if feasibility violated
                else
                    value_iter(i,k,j)=-Inf;
                end
            end
% Assign value(2,i,k) as maximum of value_iter(i,k,j) over j
            value(2,i,k)=max(value_iter(i,k,:));
        end
    end
% Determine sup difference between value(2,i,k) and
% value(1,i,k)
    sup=max(max(abs(value(2,:,:)-value(1,:,:))));
end

% 2-d arrays for policy function and index of maximizing capital value.
% Entry (i,j) is index/capital value that maximizes value(2,i,j)
policy_ind=zeros(grid_size,size_space);
policy=zeros(grid_size,size_space);
for i=1:grid_size
    for j=1:size_space
        [z,index]=max(value_iter(i,j,:));
        policy_ind(i,j)=min(index);
        policy(i,j)=k_grid(min(index));
    end
end

% Plot value function for each shock in sample_space
figure
hold on
for j=1:size_space
plot(k_grid(:),value(2,:,j))
end
xlabel('Current-Period Capital')
ylabel('Value')
title('Planner''s Value Function')
hold off


