function [yout,x] = quick_sim(gx,hx,eta,x0,shock)
x = zeros(length(x0),length(shock));
x(:,1) = x0;
for jj = 2:length(shock)
    x(:,jj) = hx*x(:,jj-1) + eta*shock(:,jj);
end
yout = gx*x;