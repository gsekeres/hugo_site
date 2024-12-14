%% BYTE5_CODE: Code examples from byte5 lecture on functional approximation
%
% Notes:
% - When approximation a function there are three choices (i) basis
% functions (ii) approximation points (iii) loss function
% - these choices interact, and there is lots of good theory proposing
% partiular choice (ii) and (iii) for certain basic functions
% - this lesson sort of ignores those details. But for economics
% applications I think the linear finite element basis functions are often
% the best option.


%% here is function that has a sort of crazy shape
f = @(x) log(x +.01) + 3*x.^4;

xfine = linspace(0,1,1000);

f1 = figure; s = plot(xfine,f(xfine), 'linewidth',2);  hold on

%Here is data we are using for our approximation
xgrid = linspace(0,1,10);
fvals = f(xgrid);

s2 = plot(xgrid, fvals, '.', 'Markersize',20); legend('True Function', 'Data Points')
%% Let try do the best approximation with 5th taylor basis functions
figure(f1)
N =5;
M = xgrid(:).^[0:N];
an = M\fvals(:);

yy =0;
for jj = 0:N
    yy = yy+ an(jj+1)*xfine.^jj;
end
p = plot(xfine,yy,'linewidth',2);


%% Let try do the best approximation with 9th taylor basis functions
figure(f1); p.Visible = false;
N =9;
M = xgrid(:).^[0:N];
an = M\fvals(:);

yy =0;
for jj = 0:N
    yy = yy+ an(jj+1)*xfine.^jj;
end
p = plot(xfine,yy,'linewidth',2);


%% Let's do chebychev at our original notes
figure(f1); p.Visible = false;
N = 4; M = zeros(length(xgrid),N+1);
for jj = 0:N
    M(:,jj+1) = chebyshevT(jj,xgrid);
end
an = M\fvals(:); 

yy =0;
for jj = 0:N
    yy = yy+ an(jj+1)*chebyshevT(jj,xfine);
end
p = plot(xfine,yy,'linewidth',2);

%% Let's evaluate off grid
yy =0;
shift = .5;
for jj = 0:N
    yy = yy+ an(jj+1)*chebyshevT(jj,xfine+shift);
end
plot(xfine+shift,yy,'linewidth',2);
