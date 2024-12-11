addpath('helper_functions')

rho = .95;
siga = 0.01;

na = 5;
[agrid, theta, theta_bar] = AR1_rouwen(na,rho,0,siga);
agrid = exp(agrid);

nper = 5000;

rng(10);   %Seed random number generator

apos    = zeros(1,nper);
apos(1) = (na-1)/2+1; %Start at middle grid points
for tt = 2:nper
    
    tprobs = theta(apos(tt-1),:);   %Choose the row that corresponds to the current t state
    
    %Random draw from [0,1]
    x = rand(1);
    
    %Think of tprobs has a segmentation of unit interval and 
    %compute what segment [0,1] does x fall on, based on tprobs
    apos(tt) = sum(x>cumsum(tprobs))+1;  
    
end

%Values of a
aval = agrid(apos);

%Checking the moments match up
std_sim   = std(log(aval))
std_exact = sqrt(siga^2/(1-rho^2))
