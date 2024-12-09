% TEST_SIMPLEX
%
% Example code to show how to use the function ndim_simplex and
% ndim_simplex_eval. For ECON6140 at Cornell.
%
% Ryan Chahrour
% ryan.chahrour@cornell.edu
% April 23, 2024

addpath('helper_functions');

xx = linspace(1,3);
yy = linspace(2,5);
z = @(x,y)  3*(x-2).^2 + 1/2.*x - 2*y*0 + 0*y.^(1/2) + (y-3).^2 - .5*(y-2).^3 + 50*sin(y);

z = @(x,y)  2*sin(x) + 3*sin(y) + 2*cos(x.*y);

zsmooth = z(xx,yy');

%Draw the smoothed function
figure
surf(xx',yy,zsmooth)
xlabel('x');
ylabel('y');
zlabel('z');
title('Function')

% Approximate it
np = 5;
xgrid = linspace(1,3,np);
ygrid = linspace(2,5,np);

[xxgr,yygr] = ndgrid(xgrid,ygrid);
zval = z(xxgr,yygr);

%Get the best fiting polynomial based on grid points
[alph,M] = ndim_simplex({xgrid,ygrid},[xxgr(:)';yygr(:)'],zval(:)');


%Evaluate approximation "off grid" at the refined xx,yy
[xxgr2,yygr2] = ndgrid(xx,yy);
zapprox = ndim_simplex_eval({xgrid,ygrid},[xxgr2(:)';yygr2(:)'],alph);

figure
surf(xx',yy,reshape(zapprox,[100,100]))
xlabel('x');
ylabel('y');
zlabel('z');
title('Approximated Function')





