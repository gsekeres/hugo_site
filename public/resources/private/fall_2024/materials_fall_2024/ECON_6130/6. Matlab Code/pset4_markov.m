%% Simulate Markov Chain

% Parameters:
K = 0.98; % persistence
mean_e = 0; % mean of the shock
LR_var_y = 0.1; % long-run variance of y
LR_mean_y = 0; % long-run mean of y
size_space = 7; % sample space (given)

% Implied variance of the shock:
var_e = (1 - K^2) * LR_var_y;

% Set the approximation nodes
% (recall: -3 and 3 standard deviations from long-run mean)
sample_space = linspace(LR_mean_y - (size_space - 1) / 2 * LR_var_y,...
    LR_mean_y + (size_space - 1) / 2 * LR_var_y, size_space);

% Find the transition matrix
trans=zeros(size_space, size_space);
for i=1:size_space
    for j=1:size_space
        if j==1
        trans(i,j)=normcdf((sample_space(j)-K*sample_space(i)+0.5*sqrt(LR_var_y))...
        /sqrt(var_e));
        elseif j==size_space
        trans(i,j)=1-normcdf((sample_space(j)-K*sample_space(i)-0.5*sqrt(LR_var_y))...
        /sqrt(var_e));
        else
        trans(i,j)=normcdf((sample_space(j)-K*sample_space(i)+0.5*sqrt(LR_var_y))...
        /sqrt(var_e))...
        -normcdf((sample_space(j)-K*sample_space(i)-0.5*sqrt(LR_var_y))...
        /sqrt(var_e));
        end
    end
end

% Calculate stationary distribution of transition matrix
A=trans'-diag(ones(1,size_space));
A(size_space,:)=ones(1,size_space);
b=zeros(size_space,1);
b(size_space)=1;
stationary=(A\b)';

% Simulate Markov Chain for T steps, with initial state distributed according 
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
saveas(gcf,'pset4_markov_matlab.png')