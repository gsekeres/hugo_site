function out = residual(kpol,npol,state_grid,allgrid,aprime,pw,param)

ns = size(state_grid,2);

passign(param)

%Time-t states
A   = state_grid(1,:);
K   = state_grid(2,:);
NL  = state_grid(3,:);

% Time-t+1 states. 
% Policy guesses to compute future state (need to rep for each possible shock between now and then)
A_p = aprime;
K_p = repmat_row(kpol,3);
N   = repmat_row(npol,3);

%Time t+1 policy
state_grid_p = [A_p(:)';K_p(:)';N(:)'];
N_p  = ndim_simplex_eval(allgrid,state_grid_p,npol(:));
K_pp = ndim_simplex_eval(allgrid,state_grid_p,kpol(:));

N_p = reshape(N_p,[3,ns]);
K_pp = reshape(K_pp,[3,ns]);

%Subsitute out some things to get time T vars
GDP = A.*K.^alph.*N(1,:).^(1-alph);
I   = K_p(1,:) - (1-delk)*K;
VAC = ((N(1,:) - (1-deln)*NL)./chi).^(1/veps);
C   = GDP-I-phin*VAC;

%To get C_p, we need to efallow the same steps at time t+1
GDP_p = A_p.*K_p.^alph.*N_p.^(1-alph);
I_p   = K_pp - (1-delk)*K_p;
VAC_p = ((N_p - (1-deln)*N)./chi).^(1/veps);
C_p     = GDP_p-I_p-phin*VAC_p;

%Main equations
out      = zeros(2,size(state_grid,2));
out(1,:) = C.^-sig-pw'*(bet*(C_p).^-sig.*(A_p.*alph.*(K_p./N_p).^(alph-1) + 1 -delk));
out(2,:) = C.^-sig.*(phin./(veps*chi*VAC.^(veps-1)) - A.*(1-alph).*(K./N(1,:)).^alph) - pw'*(bet*(C_p).^-sig*phin./(veps*chi.*VAC_p.^(veps-1))*(1-deln));



