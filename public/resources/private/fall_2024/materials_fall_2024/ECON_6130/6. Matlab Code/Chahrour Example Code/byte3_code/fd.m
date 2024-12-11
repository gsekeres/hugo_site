% FD - Use forward finite difference to approximate derivate
%
% usage:
%
% out = fd(f,x0)
%
% where
%
% f: a function handle that accept vector arguments
% x0: point for derivative


function [out,ctr] = fd(f,x0)

%Initial FD
del = .01;
fd0 = (f(x0+del) - f(x0+del))/del;

%While loop until derivative converges
crit = 1;
ctr  = 1;
while crit>1e-10 && ctr<10000
    
    %Shrink the change
    del = del/2;
    fd = (f(x0+del) - f(x0))/del;
    
    %How large is change in derivative?
    crit = max(abs((fd-fd0)/max(.01,abs(fd))));  %Why the max(.01,fd)? I wanted to compute percentage changes, but if the derivative is zero this is not well definied. The max to ensures we never divide by zero
    
    fd0 = fd;
    ctr = ctr+1;
end

out = fd;