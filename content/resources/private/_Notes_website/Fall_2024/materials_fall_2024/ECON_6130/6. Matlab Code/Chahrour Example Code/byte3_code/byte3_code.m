%% BYTE3_CODE: Code examples from byte3 lecture on root-finding 
%
% Notes:
% - function handles are a useful feature that can simplify coding
% - bisection is a robust way to find roots of univariate functions
% - most root-finding algorithms, though, are based on Newton's method


%% BISECTION EXAMPLE


f = @(x) -2 + x + 2*x.^2;

x_grid = linspace(0,1);


figure;
plot(x_grid,f(x_grid)); hold on; plot(x_grid,0*x_grid, '--');


x0 = bisect(f,[0,1])

plot(x0,0, '-kx', 'markersize', 10)


%% NEWTON METHOD
x0 = newton(f,0)