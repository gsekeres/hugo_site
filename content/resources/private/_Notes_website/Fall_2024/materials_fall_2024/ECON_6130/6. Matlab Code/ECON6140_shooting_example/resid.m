function f = resid(XYv,ss,param,log_var)

%Declare parameters
passign(param)

%Take input argument, add back steady-state
XYv = reshape(XYv,[8,numel(XYv)/8]) + ss(:);

%Put variables back into levels
XYv(log_var,:) = exp(XYv(log_var,:));
ss(log_var)    = exp(ss(log_var));

%Combine the (fixed) X0  with the guessed paths for X1, X2, ....
A  = [exp(log(ss(1))+siga),XYv(1,:)]; 
K  = [ss(2)     ,XYv(2,:)];

%Combine the guessed paths for Y0, Y1, ... with (fixed) YT
C    = [XYv(3,:),ss(3)];
H    = [XYv(4,:),ss(4)];
W    = [XYv(5,:),ss(5)];
R    = [XYv(6,:),ss(6)];
I    = [XYv(7,:),ss(7)];
VAL  = [XYv(8,:),ss(8)];

%The future vs the present
A_p = A(2:end);
K_p = K(2:end);

C_p   = C(2:end);
H_p   = H(2:end);
W_p   = W(2:end);
R_p   = R(2:end);
I_p   = I(2:end);
VAL_p = VAL(2:end);

A  = A(1:end-1);
K  = K(1:end-1);

C = C(1:end-1);
H = H(1:end-1);
W = W(1:end-1);
R = R(1:end-1);
I = I(1:end-1);
VAL = VAL(1:end-1);

%Model Equations (can use exactly same equations as in model.m, but with
%.operators)
f = zeros(8,length(XYv));
f(1,:) = C-W./chi;
f(2,:) = 1-bet*C./C_p.*(R_p+1-del);
f(3,:) = R - alph*A.*(K./H).^(alph-1);
f(4,:) = W - (1-alph)*A.*(K./H).^alph;
f(5,:) = (1-del)*K + I - K_p;
f(6,:) = C+I- A.*K.^alph.*H.^(1-alph);
f(7,:) = VAL - (log(C) - chi*H) - bet*VAL_p;
f(8,:) = log(A_p) - rho_a*log(A);
