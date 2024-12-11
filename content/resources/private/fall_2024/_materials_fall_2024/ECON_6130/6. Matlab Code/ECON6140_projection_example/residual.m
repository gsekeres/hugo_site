function out = residual(kpol,hpol,state_grid,allgrid,aprime,pw,param)

ns = size(state_grid,2);

passign(param)

%Time-t states
A   = state_grid(1,:);
K   = state_grid(2,:);

% Policy guesses to compute H and future state (need to repeat future states for each possible shock between now and then)
H   = hpol;  %Evaluate policy function at the grid point. (But no need to evaulate because of hat basis functions)
A_p = aprime;
K_p = repmat_row(kpol,3); %Kp(i,m) = Kp(i);

%Use resource constraints to get time t consumption
GDP = A.*K.^alph.*H(1,:).^(1-alph);
I   = K_p(1,:) - (1-del)*K;
C   = GDP-I;

%Time t+1 policy
state_grid_p = [A_p(:)';K_p(:)'];
H_p  = ndim_simplex_eval(allgrid,state_grid_p,hpol(:));
K_pp = ndim_simplex_eval(allgrid,state_grid_p,kpol(:));

K_pp = reshape(K_pp,[3,ns]); %Rows are different TFP shocks
H_p  = reshape(H_p,[3,ns]); %Rows are different TFP shocks

%To get C_p, we need to follow the same steps at time t+1
GDP_p  = A_p.*K_p.^alph.*H_p.^(1-alph);
I_p    = K_pp - (1-del)*K_p;
C_p    = GDP_p-I_p;
R_p    = alph*A_p.*(K_p./H_p).^(alph-1);

%Main equations
out      = zeros(2,size(state_grid,2));
out(1,:) = C.^-1-pw'*(bet*1./C_p.*(R_p+1-del));
out(2,:) = C-(1-alph)*A.*(K./H).^alph./chi;
