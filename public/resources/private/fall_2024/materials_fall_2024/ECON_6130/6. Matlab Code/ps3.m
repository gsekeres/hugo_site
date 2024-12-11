clc;
clear all;
close all;
format compact

tic

% Set parameters:
alpha = 0.3;
beta = 0.6;
delta = 0.75;
diff = 1;
tol = 1e-6;
its = 1;

% Utility function:
u = @(c) (c>0).*log(c)+(c<=0).*(-1000);

kss = 1.508;
N = 1000;
kmin = 0.25 * kss;
kmax = 1.75 * kss;
kgrid = linspace(kmin, kmax, N);

val_fun = zeros(1, N);
pol_fun_idx = zeros(1, N);

% Iterate:
while diff > tol
    for i = 1:N
        c = (kgrid(i)^alpha + (1 - delta)*kgrid(i)) - kgrid;
        [val_new(i), pol_fun_idx(i)] = max(u(c) + beta * val_fun);
    end
    diff = max(abs((val_new - val_fun)));
    val_fun = val_new;
    its = its + 1;
end

pol_fun = kgrid(pol_fun_idx);
cons = (kgrid .^ alpha) - pol_fun;

toc

% Plots:
figure(1)
plot(kgrid, pol_fun,'linewidth',1.8); title('Policy Function (k_{t+1})'); ...
    xlabel('k_t'); ylabel('k_{t+1}'); grid on ; hold on; ...
    xlim([kmin kmax]); saveas(gcf,'pset3_policy_function.png')

figure(2)
plot(kgrid, val_fun,'linewidth',1.8); title('Value Function'); ...
    xlabel('k_t'); ylabel('v(k_t)'); grid on ; hold on;  ...
    xlim([kmin kmax]); saveas(gcf,'pset3_value_function.png')