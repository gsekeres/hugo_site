function [fy,fx,fyp,fxp,fv,out6] = model_df(in1)
%MODEL_DF
%    [FY,FX,FYP,FXP,FV,OUT6] = MODEL_DF(IN1)

%    This function was generated by the Symbolic Math Toolbox version 24.2.
%    09-Dec-2024 09:45:31

alph = in1(:,5);
bet = in1(:,2);
chi = in1(:,3);
del = in1(:,4);
gam = in1(:,7);
rho = in1(:,6);
sigma = in1(:,8);
et1 = (alph-1.0).*(((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0))).^alph;
et2 = (((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(-1.0./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0))).^(-alph);
mt1 = [1.0,(chi.*gam.^(1.0./(alph-1.0)).*sigma.*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(-alph./(alph-1.0)))./(alph-1.0),0.0,0.0,0.0,1.0,-(-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./chi).^(-sigma),0.0,0.0,0.0,0.0,0.0];
mt2 = [alph.*chi.*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-2.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(-alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(2.0./(alph-1.0)).*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0)];
mt3 = [-alph.*chi.*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(-alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(2.0./(alph-1.0)).*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0),0.0,et1.*et2,chi,0.0,0.0,0.0];
mt4 = [-1.0./chi,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0];
fy = reshape([mt1,mt2,mt3,mt4],10,6);
if nargout > 1
    et3 = alph.*(((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0))).^(alph-1.0);
    et4 = -(((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(-1.0./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0))).^(-alph+1.0);
    et5 = (((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0))).^alph;
    et6 = -(((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(-1.0./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0))).^(-alph+1.0);
    mt5 = [0.0,0.0,-alph.*chi.*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-2.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(-alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0)).*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0)];
    mt6 = [alph.*chi.*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(-alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0)).*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0),-del+1.0,et3.*et4,0.0,0.0,0.0,0.0,0.0,0.0];
    mt7 = [-alph.*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0),(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^alph.*(alph-1.0),0.0,et5.*et6,0.0,-rho,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-1.0,0.0];
    fx = reshape([mt5,mt6,mt7],10,4);
end
if nargout > 2
    fyp = reshape([0.0,-(chi.*gam.^(1.0./(alph-1.0)).*sigma.*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(-alph./(alph-1.0)))./(alph-1.0),0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-bet,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-bet,0.0,0.0,0.0],[10,6]);
end
if nargout > 3
    fxp = reshape([0.0,0.0,0.0,0.0,-1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,1.0],[10,4]);
end
if nargout > 4
    et7 = -((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0));
    et8 = ((gam.^(1.0./(alph-1.0)).*(del-1.0)+1.0).*(alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0));
    et9 = -((alph-1.0).*(del-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0));
    et10 = (((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0))).^alph;
    et11 = -(((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(-1.0./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0))).^(-alph+1.0);
    et12 = 1.0./(bet-1.0);
    et13 = -(log(-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./chi)-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(-1.0./(alph-1.0)))./(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0));
    et14 = bet./(bet-1.0);
    et15 = log(-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./chi)-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(-1.0./(alph-1.0)))./(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0);
    et16 = (-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./chi).^(-sigma+1.0)./(sigma-1.0)+et12.*et13+et14.*et15;
    et17 = ((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(-1.0./(alph-1.0)))./(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0);
    mt8 = [0.0,-gam.^(1.0./(alph-1.0))+1.0,del+gam.^(1.0./(alph-1.0))./bet-alph.*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)-1.0,(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^alph.*(alph-1.0)-(alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)),et7+et8+et9];
    mt9 = [et10.*et11-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./chi+((gam.^(1.0./(alph-1.0)).*(del-1.0)+1.0).*(alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0)),et16+et17,0.0,0.0,0.0];
    fv = [mt8,mt9];
end
if nargout > 5
    et18 = 1.0./(bet-1.0);
    et19 = -(log(-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./chi)-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(-1.0./(alph-1.0)))./(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0));
    mt10 = [-((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./chi,((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(-1.0./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0))];
    mt11 = [-(alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)),del+gam.^(1.0./(alph-1.0))./bet-1.0,((gam.^(1.0./(alph-1.0)).*(del-1.0)+1.0).*(alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0)),et18.*et19];
    mt12 = [((alph-1.0).*((del+gam.^(1.0./(alph-1.0))./bet-1.0)./alph).^(alph./(alph-1.0)))./(chi.*(gam.^(1.0./(alph-1.0)).*(del-1.0)-gam.^(alph./(alph-1.0)).*(((del+gam.^(1.0./(alph-1.0))./bet-1.0)./(alph.*gam)).^(1.0./(alph-1.0))).^(alph-1.0)+1.0)),0.0,0.0,0.0];
    out6 = [mt10,mt11,mt12];
end
end
