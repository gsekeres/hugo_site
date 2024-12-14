%**************************************************************************
% SOLVE_VF: Example code for ECON6140. Solves the (stationary) neoclassical
% model using value-function iteration and a discrete choice set for
% captial and labor.
%
% PROBLEM:
%
% V(K,A) = max_{H(t),K(t+1)} log(C(t)) - chi*H(t) + bet*E[V(K(t+1),A(t+1)]}
%
% subject to
%
% C(t) + K(t+1) - (1-del)*K(t) = A(t)*K(t)^alph*H(t)^(1-alph)
%
%
% This code is a demonstration of the value function technique, NOT a
% suggestion that this is best approach to solving the RBC model. (It is
% not.) To get reasonably accurate solutions you will need to use more grid
% points than I have included by default here.
%
% Ryan Chahrour
% Cornell University
% November 2024
%**************************************************************************
addpath('helper_functions')

%% Solve linear version of model
linear_model
rehash
param = parameters;
pval  = struct2array(param);

[fy,fx,fyp,fxp,ftest,yxss] = model_df(pval');
[gx,hx] = gx_hx_alt(fy,fx,fyp,fxp);
eta = [0;1];

%% The value function iteration

%put parameter value in memory
passign(param);

%steady-state stuff
abar = yxss(a_idx);
kbar = yxss(k_idx);
cbar = yxss(c_idx);
hbar = yxss(h_idx);
vbar = yxss(val_idx);

%Agrid - in logs
na = 5;
[agrid, theta, theta_bar] = AR1_rouwen(na,rho_a,0,sige);
agrid = exp(agrid);

%Kgrid - in levels
nk    = 50;
kgrid = linspace(.9*kbar,1.1*kbar,nk);

%Hgrid - in levels
nh    = 150;
hgrid = linspace(.8*hbar,1.2*hbar,nh);

%A/K combos as initial states
[aagr,kkgr] = ndgrid(agrid,kgrid);
aagr = aagr(:)' ;
kkgr = kkgr(:)';

%K/H combos to choose from
[kkgr2,hhgr2] = ndgrid(kgrid,hgrid);
kkgr2 = kkgr2(:)';  
hhgr2 = hhgr2(:)';


%Initial policy functions for K(t+1), N(t)
kinit = kbar + hx(2,:)*[aagr-abar;kkgr-kbar];
kinit = reshape(kinit,[na,nk]);

hinit = hbar + gx(h_idx,:)*[aagr-abar;kkgr-kbar];
hinit = reshape(hinit,[na,nk]);

vinit = vbar + gx(val_idx,:)*[aagr-abar;kkgr-kbar];
vinit = reshape(vinit,[na,nk]);



%**************************************************************************
% MAIN LOOP
%**************************************************************************
idx  = zeros(na,nk); crit = 1; jj = 0;
tic

%Fixing policy for nfix>1 iteration speeds up computations. Standard VF has
%nfix = 1.
nfix = 25;

%Initial value function
while crit > 1e-6 && jj < 1000
    vinit_old = vinit; %Tracking for computing covergence criterion

     %Computing expectations for each current A(t), for each possisble choice K(t+1), N(t) choice on grid
     EVp   = repmat(theta*vinit,1,nh);

    if mod(jj,nfix) == 0
        for aa = 1:na     %For each value of A(t)

            for kk = 1:nk %For each value of K(t),N(t-1)

                %Current States
                at  = agrid(aa);
                kt  = kgrid(kk);
                
                %Impose constraints
                gdp = at.*kt.^alph.*hhgr2.^(1-alph);
                it  = kkgr2-(1-del)*kt;
                ct  = gdp-it;
                
                %Recompute value function under conjectured policy
                vv = -inf + ones(1,size(EVp,2));
                idxp = ct>0;%Drop infeasible combos
                vv(idxp) = log(ct(idxp)) - chi*hhgr2(idxp) + bet*EVp(aa,idxp);

                %Updating value function using best policies.
                %Note that this code is "Gauss-Seidel": it uses the updated
                %values for each entry of vinit as soon as they are commputed.
                [vinit(aa,kk),idx_tmp] = max(vv);
                idx(aa,kk) = idx_tmp;

            end
        end

    else

        %E(v) conditioned on A(t) and optimal K(t+1)/N(t)
        evp_k = zeros(na,nk);
        for aa = 1:na
            for kk = 1:nk
                evp_k(aa,kk) = EVp(aa,idx(aa,kk));
            end
        end

        %Recompute value using conjectured value function
         gdp = aagr.*kkgr.^alph.*hhgr2(idx(:)).^(1-alph);
         it  = kkgr2(idx(:))-(1-del)*kkgr;
         ct  = gdp-it;

        %Recompute value function under conjectured policy
        vv = log(ct) - chi*hhgr2(idx(:)) + bet*evp_k(:)';

        vinit = reshape(vv,[na,nk]);

    end
    crit = max(max(abs(vinit-vinit_old)));
    vinit_old = vinit;
    disp(['Iter ' num2str(jj) ': ' num2str(crit, '%2.2e')]);
    jj=jj+1;
end
toc

kpol = reshape(kkgr2(idx(:)),[na,nk]);
hpol = reshape(hhgr2(idx(:)),[na,nk]);
%%

%%

figure;
subplot(3,2,1);
plot(kgrid,hpol(1,:), 'linewidth',2); ylabel('low A'); xlabel('K'); title('H policy')
hold on
plot(kgrid, hinit(1,:), '--','linewidth',2);
subplot(3,2,2)
plot(kgrid,kpol(1,:),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(1,:), '--','linewidth',2);

subplot(3,2,3);
plot(kgrid,hpol(3,:), 'linewidth',2); ylabel('mid A');
hold on
plot(kgrid, hinit(3,:), '--','linewidth',2);
subplot(3,2,4)
plot(kgrid,kpol(3,:),'linewidth',2);
hold on
plot(kgrid, kinit(3,:), '--','linewidth',2);

subplot(3,2,5);
plot(kgrid,hpol(5,:), 'linewidth',2); ylabel('high A');
hold on
plot(kgrid, hinit(5,:), '--','linewidth',2);
subplot(3,2,6)
plot(kgrid,kpol(5,:),'linewidth',2);
hold on
plot(kgrid, kinit(5,:), '--','linewidth',2);

legend('Non-linear policy','Linear Policy');








