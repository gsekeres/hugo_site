% AR1_rouwen - Generate the rouwen-matrix dicrete approximation to an AR1
% process.  Follows Kopecky & Suen, 2010, "Finite state Markov-chain
% approximations to highly persistent processes"
%
% usage
%
% [grid, theta, theta_bar] = AR1_rouwen(N,rho,mu,sige)
%
% where
%
% N = the number of grid points
% rho = the AR persistence parameters
% mu = the mean of the AR process
% sige = the std dev of the shock to the AR process


function [grid, theta, theta_bar] = AR1_rouwen(N,rho,mu,sige)

%Parameters
p = (1+rho)/2;
q = p;
sigz = sqrt(sige^2/(1-rho^2));
phi = sqrt(N-1)*sigz;

grid = linspace(mu-phi, mu+phi,N);

%Construct rouwenhorst matrix
theta = [p 1-p; 1-q q];
for j =3:N
    theta =  p *  [theta          zeros(j-1,1);  zeros(1,j-1) 0           ]  + ...
            (1-p)*[zeros(j-1,1)   theta       ; 0             zeros(1,j-1)]  + ...
            (1-q)*[zeros(1,j-1)   0           ; theta         zeros(j-1,1)]  + ...
             q *  [0 zeros(1,j-1)             ; zeros(j-1,1), theta       ];
         
    for kk = 2:j-1
        theta(kk,:) = theta(kk,:)/sum(theta(kk,:));
    end
end


%Steady State probs
if rho > 0
    [D,V] = eig(-theta');
    theta_bar = D(:,1)./sum(D(:,1));
    theta_bar = theta_bar';
else
    theta_bar = mean(theta^1000);
end