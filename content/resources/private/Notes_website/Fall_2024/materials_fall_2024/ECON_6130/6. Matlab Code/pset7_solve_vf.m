clear;
format long;
tic;

% Add helper functions
addpath('/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Matlab/pset7_helper_functions')

% Load parameters
param = pset7_parameters;

bet = param.bet;
sig = param.sig;
alpha = param.alpha;
deltak = param.deltak;
deltan = param.deltan;
phin = param.phin;
chi = param.chi;
eps = param.eps;
rho = param.rho;
siga = param.siga;

% Solve the linear model
pset7_linear_model;
rehash;
pval  = struct2array(param);

[fy,fx,fyp,fxp,ftest,yxss] = pset7_model_df(pval');
[gx,hx] = gx_hx_alt(fy,fx,fyp,fxp);
eta = [0 ; 1];
disp(gx);
disp(hx);
disp(yxss);

%put parameter value in memory
passign(param);

%steady-state stuff
abar = yxss(a_idx);
kbar = yxss(k_idx);
cbar = yxss(c_idx);
nbar = yxss(n_idx);
vbar = yxss(val_idx);

%Agrid - in logs
na = 5;
[agrid, theta, theta_bar] = AR1_rouwen(na,rho,0,siga);
agrid = exp(agrid);


disp("Markov transition matrix:");
disp(theta);

disp("Stationary distribution:");
disp(theta_bar);

% Compute the expected value of A_t
E_At = theta_bar *agrid';
disp(['Expected value of A_t: ', num2str(E_At)]);

%Kgrid - in levels
nk    = 50;
kgrid = linspace(.9*kbar,1.1*kbar,nk);

%Hgrid - in levels
nn    = 150;
ngrid = linspace(.8*nbar,1.2*nbar,nn);

%A/K/N combos as initial states
[aagr,kkgr,nngr] = ndgrid(agrid,kgrid,ngrid);
aagr = aagr(:)' ;
kkgr = kkgr(:)';
nngr = nngr(:)';

%K/N combos to choose from
[kkgr2,nngr2] = ndgrid(kgrid,ngrid);
kkgr2 = kkgr2(:)';  
nngr2 = nngr2(:)'; 

%Initial policy functions for K(t+1), N(t)
kinit = kbar + hx(2,:)*[aagr-abar;kkgr-kbar;nngr-nbar];
kinit = reshape(kinit,[na,nk*nn]);

ninit = nbar + gx(n_idx,:)*[aagr-abar;kkgr-kbar;nngr-nbar];
ninit = reshape(ninit,[na,nk*nn]);

vinit = vbar + gx(val_idx,:)*[aagr-abar;kkgr-kbar;nngr-nbar];
vinit = reshape(vinit,[na,nk*nn]);


disp("Initial value function:");
EV_init = theta * vinit;
disp(EV_init(1,1));

% Optimize the value function
idx = zeros(na, nk, nn); crit = 1; jj = 0;

nfix = 1;

while (crit > 1e-6) && (jj < 1000)
    vinit_old = vinit;
    EVp = theta * vinit;
    vinit = reshape(vinit, na, nk, nn);

    if mod(jj,nfix) == 0
        for aa = 1:na
            for kk = 1:nk
                for nm = 1:nn
                    % State
                    at = agrid(aa);
                    kt = kgrid(kk);
                    nt = ngrid(nm);

                    % Constraints
                    Yt = at .* kt.^alpha .* nngr2 .^ (1 - alpha);
                    vt = ((nngr2 - (1 - deltan) * nt) / chi) .^ (1 / eps);
                    it = kkgr2 - (1 - deltak) * kt;
                    ct = Yt - it - phin * vt;

                    % Compute value function
                    vv = -inf + ones(1,size(EVp,2));
                    idxp = ct>0;
                    vv(idxp) = (ct(idxp) .^ (1 - sig)) / (1 - sig) + bet*EVp(aa,idxp);

                    % Update value function
                    [vinit(aa,kk,nm),idx_tmp] = max(vv);
                    idx(aa,kk,nm) = idx_tmp;
                end
            end
        end
        vinit = reshape(vinit, na, nk*nn);
    else
        evp_k = zeros(na,nk,nn);
        for aa = 1:na
            for kk = 1:nk
                for nm = 1:nn
                    evp_k(aa,kk,nm) = EVp(aa,idx(aa,kk,nm));
                end
            end
        end
        evp_k = reshape(evp_k, na, nk*nn);

        % Constraints
        Yt = aagr .* kkgr.^alpha .* nngr(idx(:)).^(1 - alpha);
        it = kkgr2(idx(:)) - (1 - deltak) * kkgr;
        vt = ((nngr2(idx(:)) - (1 - deltan) * nngr) / chi) .^ (1 / eps);
        ct = Yt - it - phin * vt;

        % Update value function
        vv = (ct.^(1 - sig)) / (1 - sig) + bet*evp_k(:)';

        vinit = reshape(vv, [na,nk*nn]);
    end

    crit = max(max(abs(vinit - vinit_old)));
    vinit_old = vinit;
    disp(['Iteration: ', num2str(jj), ' Crit: ', num2str(crit, '%2.2e')]);
    jj = jj + 1;
end 

% Final
disp("Final value function:");
exactvinit = vinit;
disp(exactvinit(1,1,1));

% Plot the policy functions
kpol = reshape(kkgr2(idx(:)),na,nk,nn);
npol = reshape(nngr2(idx(:)),na,nk,nn);

kinitpol = reshape(kinit,[na,nk,nn]);
ninitpol = reshape(ninit,[na,nk,nn]);

% Define colors
calm_blue = [0.2, 0.6, 0.8];
calm_green = [0.2, 0.8, 0.2];

figure;
subplot(1,2,1);
plot(kgrid,npol(3,:,75), 'linewidth',2, 'Color', calm_blue); ylabel('low A'); xlabel('K'); title('N policy')
hold on
plot(kgrid,ninitpol(3,:,75),'LineWidth',2,'Color',calm_green);

subplot(1,2,2);
plot(kgrid,kpol(3,:,75), 'linewidth',2, 'Color', calm_blue); ylabel('low A'); xlabel('K'); title('K policy')
hold on
plot(kgrid,kinitpol(3,:,75),'LineWidth',2,'Color',calm_green);

legend('Non-linear policy','Linear Policy');

saveas(gcf, '/Users/gabesekeres/Dropbox/Notes/Cornell_Notes/Fall_2024/Macro/Matlab/pset7_policy_functions.png');


% Simulate over 5000 periods
mc = dtmc(theta);
x = simulate(mc,5000);
ks = kgrid(25);
ns = ngrid(75);

npol = reshape(npol,na,nk,nn);
kpol = reshape(kpol,na,nk,nn);


vect= zeros(5000,4);
for u  = 1:5000

    nc = npol(x(u),find(kgrid==ks),find(ngrid==ns));
    kc = kpol(x(u),find(kgrid==ks),find(ngrid==ns));

    y = ks^(alpha)*nc^(1-alpha);
    i = kc-(1-deltak)*ks;
    v = ((nc-(1-deltan)*ns)/chi)^(1/eps);
    c = y-i-phin*v;

    vect(u,:) =[y c i nc];

    ns = nc;
    ks = kc;

end

lvect = log(vect);

% Standard deviations value function model

disp("Standard deviations value function model:");
disp(['Y: ', num2str(std(lvect(:,1)))]);
disp(['C: ', num2str(std(lvect(:,2)))]);
disp(['I: ', num2str(std(lvect(:,3)))]);
disp(['N: ', num2str(std(lvect(:,4)))]);





toc;