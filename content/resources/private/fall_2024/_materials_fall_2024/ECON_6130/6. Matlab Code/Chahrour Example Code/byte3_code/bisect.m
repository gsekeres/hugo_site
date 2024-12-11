% BISECT - Use bisection to solve a scalar equation f(x) = 0.
%
% usage:
%
% out = bisect(f,x0)
%
% where
%
% f: a function handle that accept vector arguments
% x0: a 1x2 vector of initial endpoints


function out = bisect(f,x0)

f0 = f(x0);

if sign(f0(1)) == sign(f0(2))
    error('Need to have different signs at endpoints.')
end

crit = diff(x0);

ctr = 1;
while crit > 1e-10 && ctr < 1000000
    
   %Get midpoint
   mid = sum(x0)/2;
   f_new = f(mid);
   
   %Replace whichever end needs it
   if sign(f_new) == sign(f0(1))
       x0(1) = mid;
   elseif sign(f_new)==sign(f0(2))
       x0(2) = mid;
   end
      
   %Update and test for convergence
   f0 = f(x0);
   crit = diff(x0);
   ctr = ctr+1;
end

out = mean(x0);