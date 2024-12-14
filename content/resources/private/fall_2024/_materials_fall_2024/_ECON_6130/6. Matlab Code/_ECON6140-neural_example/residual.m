function out = residual(coeff_all,state_grid,aprime_p,pw,param,nh,nparam,a,stdz_x,stdz_y)

ns = size(state_grid,2);

passign(param)

%Time-t states
K   = state_grid(1,:);
A   = exp(state_grid(2,:));

%Evaluate capital policy
[bias_k,weights_k] = nn_pack(coeff_all(1:nparam),nh);
K_p = nn_eval(state_grid,nh,bias_k,weights_k,a,stdz_x,stdz_y{1});
K_p = repmat_row(K_p,3); %Kp(i,m) = Kp(i);

%Evaluate labor policy
[bias_h,weights_h] = nn_pack(coeff_all(nparam+1:end),nh);
H   = nn_eval(state_grid,nh,bias_h,weights_h,a,stdz_x,stdz_y{2});

%Use resource constraints to get time t consumption
GDP = A.*K.^alph.*H(1,:).^(1-alph);
I   = K_p(1,:) - (1-del)*K;
C   = GDP-I;

%T+1 states
state_grid_p = [K_p(:)';aprime_p];


%Time t+1 policy
K_pp = nn_eval(state_grid_p,nh,bias_k,weights_k,a,stdz_x,stdz_y{1});
H_p  = nn_eval(state_grid_p,nh,bias_h,weights_h,a,stdz_x,stdz_y{2});

A_p = reshape(exp(state_grid_p(2,:)),[3,ns]);

K_pp = reshape(K_pp,[3,ns]); %Rows are different TFP shocks
H_p  = reshape(H_p,[3,ns]); %Rows are different TFP shocks

%To get C_p, we need to follow the same steps at time t+1
GDP_p  = A_p.*K_p.^alph.*H_p.^(1-alph);
I_p    = K_pp - (1-del)*K_p;
C_p    = GDP_p-I_p;
R_p    = alph*A_p.*(K_p./H_p).^(alph-1);

%Main equations
out      = zeros(2,size(state_grid,2));
out(1,:) = 1-pw'*(bet*C./C_p.*(R_p+1-del));
out(2,:) = C-(1-alph)*A.*(K./H).^alph./chi;
