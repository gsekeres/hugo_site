% NEWTON - Use Newton's method to solve a scalar equation
%
% usage:
%
% out = newton(f,x0)
%
% where
%
% f: a function handle that accept vector arguments
% x0: initial guess


function out = newton(f,x0)

%Intialize residual
f0 = f(x0);

crit = 1;
ctr = 1;

while crit > 1e-10 && ctr<10000
    
    %Get derivative
    fprime = fd(f,x0);
    
    %Compute the step
    step = f0/fprime;
    
    %Update x and f(x)
    x0 = x0 - step;
    f0 = f(x0);
    
    %Check convergence
    crit = abs(step);
    
end
out = x0;


