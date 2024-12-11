function [gx,hx,exitflag]=pset5_gx_hx(fy,fx,fyp,fxp,stake)
    if nargin<5
        stake=1;
    end
    exitflag = 1;
    
    %Create system matrices A,B
    A = [-fxp -fyp];
    B = [fx fy];
    NK = size(fx,2);
    
    %Complex Schur Decomposition
    [s,t,q,z] = qz(A,B);   
    
    %Pick non-explosive (stable) eigenvalues
    slt = (abs(diag(t))<stake*abs(diag(s)));  
    nk=sum(slt);
    
    %Reorder the system with stable eigs in upper-left
    [s,t,~,z] = ordqz(s,t,q,z,slt);   
    
    %Split up the results appropriately
    z21 = z(nk+1:end,1:nk);
    z11 = z(1:nk,1:nk);
    
    s11 = s(1:nk,1:nk);
    t11 = t(1:nk,1:nk);
    
    %Catch cases with no/multiple solutions
    if nk>NK
        warning('The Equilibrium is Locally Indeterminate')
        exitflag=2;
    elseif nk<NK
        warning('No Local Equilibrium Exists')
        exitflag = 0;
    elseif rank(z11)<nk
        warning('Invertibility condition violated')
        exitflag = 3;
    end

    %Compute the Solution
    z11i = z11\eye(nk);
    gx = real(z21*z11i);  
    hx = real(z11*(s11\t11)*z11i);
end    