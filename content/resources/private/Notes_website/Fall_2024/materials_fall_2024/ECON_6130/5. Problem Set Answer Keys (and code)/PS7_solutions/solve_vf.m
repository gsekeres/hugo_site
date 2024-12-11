%**************************************************************************
% SOLVE_VF: Example code for ECON6140. Solves the (stationary) neoclassical
% model using value-function iteration and a discrete choice set for
% captial and labor.
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
nbar = yxss(n_idx);
vacbar = yxss(vac_idx);
vbar = yxss(val_idx);

%Agrid - in logs
na = 5;
[agrid, theta, theta_bar] = AR1_rouwen(na,rho,0,siga);
agrid = exp(agrid);

%Kgrid - in levels
nk    = 50;
kgrid = linspace(.9*kbar,1.1*kbar,nk);

%Ngrid - in levels
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
kinit = reshape(kinit,[na,nk,nn]);

ninit = nbar + hx(3,:)*[aagr-abar;kkgr-kbar;nngr-nbar];
ninit = reshape(ninit,[na,nk,nn]);

vinit = vbar + gx(val_idx,:)*[aagr-abar;kkgr-kbar;nngr-nbar];
vinit = reshape(vinit,[na,nk*nn]);



%**************************************************************************
% MAIN LOOP
%**************************************************************************
idx  = zeros(na,nk*nn); crit = 1; jj = 0;
tic

%Fixing policy for nfix>1 iteration speeds up computations. Standard VF has
%nfix = 1.
nfix = 25;

%Initial value function
while crit > 1e-6 && jj < 1000
    vinit_old = vinit; %Tracking for computing covergence criterion

    if mod(jj,nfix) == 0

        %Computing expectations for each current A(t), for each possisble choice K(t+1), N(t) choice on grid
        EVp   = theta*vinit;

        for aa = 1:na     %For each value of A(t)

            for kk = 1:nk*nn %For each value of K(t),N(t-1)

                %Current States
                at  = agrid(aa);
                kt  = kkgr2(kk);
                ntl = nngr2(kk);

                %Impose constraints
                vt  = ((nngr2-(1-deln)*ntl)./chi).^(1/veps);
                it  = kkgr2-(1-delk)*kt;
                ct  = at.*kt.^alph.*nngr2.^(1-alph)-it-phin*vt;

                %Recompute value function under conjectured policy
                vv = -inf + ones(1,size(EVp,2));
                idxp = ct>0;%Drop infeasible combos
                vv(idxp) = ct(idxp).^(1-sig)./(1-sig) + bet*EVp(aa,idxp);

                %Updating value function using best policies.
                %Note that this code is "Gauss-Seidel": it uses the updated
                %values for each entry of vinit as soon as they are commputed.
                [vinit(aa,kk),idx_tmp] = max(vv);
                idx(aa,kk) = idx_tmp;

            end
        end
    else

        %E(V) condition on A(t) and each possible K(t+1)/N(t)
        EVp   = theta*vinit;

        %E(v) conditioned on A(t) and optimal K(t+1)/N(t)
        evp_k = zeros(na,nk*nn);
        for aa = 1:na
            for kk = 1:nk*nn
                evp_k(aa,kk) = EVp(aa,idx(aa,kk));
            end
        end

        %Recompute value using conjectured value function
        vt  = ((nngr2(idx(:))-(1-deln)*nngr)./chi).^(1/veps);
        it  = kkgr2(idx(:))-(1-delk)*kkgr;
        ct  = aagr.*kkgr.^alph.*nngr2(idx(:)).^(1-alph)-it-phin*vt;

        %Recompute value function under conjectured policy
        vv = ct.^(1-sig)./(1-sig) + bet*evp_k(:)';

        vinit = reshape(vv,[na,nk*nn]);

    end
    crit = max(max(abs(vinit-vinit_old)));
    vinit_old = vinit;
    disp(['Iter ' num2str(jj) ': ' num2str(crit, '%2.2e')]);
    jj=jj+1;
end
toc

kpol = reshape(kkgr2(idx(:)),[na,nk,nn]);
npol = reshape(nngr2(idx(:)),[na,nk,nn]);
%%

figure;
subplot(3,2,1);
plot(kgrid,npol(1,:,floor(nn/2)), 'linewidth',2); ylabel('low A'); xlabel('K'); title('N policy')
hold on
plot(kgrid, ninit(1,:,floor(nn/2)), '--','linewidth',2);
subplot(3,2,2)
plot(kgrid,kpol(1,:,floor(nn/2)),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(1,:,floor(nn/2)), '--','linewidth',2);

subplot(3,2,3);
plot(kgrid,npol(3,:,floor(nn/2)), 'linewidth',2); ylabel('med A'); xlabel('K'); title('N policy')
hold on
plot(kgrid, ninit(3,:,floor(nn/2)), '--','linewidth',2);
subplot(3,2,4)
plot(kgrid,kpol(3,:,floor(nn/2)),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(3,:,floor(nn/2)), '--','linewidth',2);

subplot(3,2,5);
plot(kgrid,npol(1,:,floor(nn/2)), 'linewidth',2); ylabel('low A'); xlabel('K'); title('N policy')
hold on
plot(kgrid, ninit(1,:,floor(nn/2)), '--','linewidth',2);
subplot(3,2,6)
plot(kgrid,kpol(1,:,floor(nn/2)),'linewidth',2); title('K policy')
hold on
plot(kgrid, kinit(1,:,floor(nn/2)), '--','linewidth',2);

legend('Non-linear policy','Linear Policy');







%%
figure;
subplot(3,2,1);
plot(ngrid,squeeze(npol(1,floor(nk/2),:)), 'linewidth',2); ylabel('low A'); xlabel('N'); title('N policy')
hold on
plot(ngrid, squeeze(ninit(1,floor(nk/2),:)), '--','linewidth',2);
subplot(3,2,2)
plot(ngrid,squeeze(kpol(1,floor(nk/2),:)),'linewidth',2); title('K policy')
hold on
plot(ngrid, squeeze(kinit(1,floor(nk/2),:)), '--','linewidth',2);


subplot(3,2,3);
plot(ngrid,squeeze(npol(3,floor(nk/2),:)), 'linewidth',2); ylabel('low A'); xlabel('N'); title('N policy')
hold on
plot(ngrid, squeeze(ninit(3,floor(nk/2),:)), '--','linewidth',2);
subplot(3,2,4)
plot(ngrid,squeeze(kpol(3,floor(nk/2),:)),'linewidth',2); title('K policy')
hold on
plot(ngrid, squeeze(kinit(3,floor(nk/2),:)), '--','linewidth',2);


subplot(3,2,5);
plot(ngrid,squeeze(npol(5,floor(nk/2),:)), 'linewidth',2); ylabel('low A'); xlabel('N'); title('N policy')
hold on
plot(ngrid, squeeze(ninit(5,floor(nk/2),:)), '--','linewidth',2);
subplot(3,2,6)
plot(ngrid,squeeze(kpol(5,floor(nk/2),:)),'linewidth',2); title('K policy')
hold on
plot(ngrid, squeeze(kinit(5,floor(nk/2),:)), '--','linewidth',2);

legend('Non-linear policy','Linear Policy');





