function out = pset8_residual(kpol,npol,state_grid,allgrid,aprime,pw,param)

    ns = size(state_grid,2);

    bet = param.bet;
    sigma = param.sig ;
    alph = param.alpha ;  
    deltak = param.deltak;
    deltan = param.deltan;
    phin = param.phin;
    chi = param.chi;
    eps = param.eps;
    
    %Time-t states
    A   = state_grid(1,:);
    K   = state_grid(2,:);
    N   = state_grid(3,:);
    
    % Policy guesses to compute H and future state (need to repeat future states for each possible shock between now and then)
    A_p = aprime;
    K_p = kpol;
    K_p = repmat_row(K_p,3);
    N_p = npol;
    N_p = repmat_row(N_p,3);
    
    %Subsitute out some things to get time T vars
    GDP = A.*K.^alph.*N_p(1,:).^(1-alph);
    I   = K_p(1,:) - (1-deltak)*K;
    V   = ((N_p(1,:) - (1-deltan)*N)/chi).^(1/eps);
    C   = GDP-I-phin*V;
    
    %Time t+1 policy
    
    state_grid_p = [repmat(A_p(:),7*21,1)';K_p(:)';N_p(:)'];
    
    N_pp  = ndim_simplex_eval(allgrid,state_grid_p,npol(:));
    K_pp = ndim_simplex_eval(allgrid,state_grid_p,kpol(:));
    
    K_pp = reshape(K_pp,[3,ns]); %Rows are different TFP shocks
    N_pp  = reshape(N_pp,[3,ns]); %Rows are different TFP shocks
    
    A_p = repmat(A_p(:)',7*21,1)';
    A_p = reshape(A_p,[3,ns]);
    
    %To get C_p, we need to follow the same steps at time t+1
    GDP_p  = A_p.*K_p.^alph.*N_pp.^(1-alph);
    I_p    = K_pp - (1-deltak)*K_p;
    V_p   = ((N_pp - (1-deltan)*N_p)/chi).^(1/eps);
    C_p    = GDP_p-I_p-phin*V_p;
    
    %Main equations
    out = zeros(2,size(state_grid,2));
    out(1,:) = C.^(-sigma)-bet.*pw'*(C_p.^(-sigma).*(A_p.*alph.*(K_p./N_pp).^(alph-1)+(1-deltak)));
    out(2,:) = C.^(-sigma).*(phin./(eps.*chi.*V.^(eps-1)) - A.*(1-alph).*(K./N_p(1,:)).^(alph))-bet*pw'*(C_p.^(-sigma).*((1-deltan).*phin)./(eps.*chi.*V_p.^(eps-1)));
    



end