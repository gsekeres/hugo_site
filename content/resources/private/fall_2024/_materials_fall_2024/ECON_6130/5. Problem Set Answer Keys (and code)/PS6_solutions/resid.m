function f = resid(XYv,XYss,param)

XYv = reshape(XYv,[8,numel(XYv)/8]);

%Declare parameters
bet  = param.bet;
sig  = param.sig;
alph = param.alph;
delk = param.delk;
deln = param.deln;
phin = param.phin;
veps = param.veps;
chi  = param.chi;
rho  = param.rho;
siga = param.siga;


A  = [exp(log(XYss(1))+siga),XYv(1,:)];
K  = [XYss(2)     ,XYv(2,:)];
NL = [XYss(3)     ,XYv(3,:)];

GDP = [XYv(4,:),XYss(4)];
C   = [XYv(5,:),XYss(5)];
I   = [XYv(6,:),XYss(6)];
N   = [XYv(7,:),XYss(7)];
V   = [XYv(8,:),XYss(8)];


%The future vs the present
A_p = A(2:end);
K_p = K(2:end);
N_p = N(2:end);
C_p = C(2:end);
V_p = V(2:end);
NL_p = NL(2:end);

A  = A(1:end-1);
K  = K(1:end-1);
NL = NL(1:end-1);
GDP = GDP(1:end-1);
C = C(1:end-1);
I = I(1:end-1);
N = N(1:end-1);
V = V(1:end-1);

%Model Equations
f = zeros(8,length(XYv));
f(1,:) = GDP - A.*K.^alph.*N.^(1-alph);
f(2,:) = (1-delk).*K + I - K_p;
f(3,:) = N - (1-deln).*NL - chi.*V.^veps;
f(4,:) = GDP - C - I - phin.*V;
f(5,:) = 1-bet.*(C_p./C).^-sig.*(A_p.*alph.*(K_p./N_p).^(alph-1) + 1 -delk);
f(6,:) = phin./(veps.*chi.*V.^(veps-1)) - A.*(1-alph).*(K./N).^alph - bet.*(C_p./C).^-sig.* phin./(veps.*chi.*V_p.^(veps-1)).*(1-deln);
f(7,:) = log(A_p) - rho*log(A);
f(8,:) = NL_p-N;