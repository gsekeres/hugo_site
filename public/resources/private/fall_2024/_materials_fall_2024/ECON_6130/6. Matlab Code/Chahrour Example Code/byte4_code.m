%% BYTE4_CODE: Code examples from byte4 lecture on random numbers 
%
% Notes:
% - "random numbers" on the computer all start with a l-o-o-o-n-g list of numbers that are uniformly distributed between [0,1].
% - parfor loops are common for simulations, but create extra issues with random number seeding
% - drawing from other (not-built-in) distributions requires using inverse-transform sampling

%% Pseudo-random numbers
clc

%Everytime you start matlab, the random seed is initialized. 
t = rand(1,1)  %This line gives the same result everytime you run right after restarting matlab


%To get code to give a nearly "random" answer each time you run
rng(1000*sum(clock));
t = rand(1,1)

%To get code to give the same answer across runs, must 'seed' generator
for jj = 1:3
    rng(123456789)
    t = rand(1,1)
end


%Matlab has a few other distributions built in
t = randn(2,10)     %Normal

t = randi(100,2,10) %Random integer

%% PARFOR LOOPS - Dangerous for replication
rng(0)
rout = zeros(1,10);
parfor ii = 1:10
    rout(ii) = randn(1,1);
end
rout

%% PARFOR LOOPS - Safe for replication
rng(0)
pseed = 1000*rand(1,10);
parfor ii = 1:10
   rng(pseed(ii));
   rout(ii) = randn(1,1);
end
rout

%% Inverse-Transform Sampling exmaple: Drawing from U[0,1] to get N(0,1)
x = rand(1,1000000);  %Samples from U[0,1]

y = norminv(x);       %Inverse normal CDF -> y is normal(0,1)


mean(y)
var(y)
subplot(1,2,1); hist(x,100);
subplot(1,2,2); hist(y,100);

