% PARAMETETRS - This function returns a parameter structure to use in the model solution.
%
%


function [param,set] = parameters()



%Parameters are values that are to be estiamted. They are passed as the 
%first argument to model_prog.m.
param.siga = .04; %Standard deviation of TFP growths shocks

%Settings are values that you 'calibrate' and therefore do change in
%estimation. They are passed as the second argument to model_prog.m
param.bet   = 0.98;  %Never call anything beta...it's a matlab function
param.chi   = 1.0;   %Disutility of labor
param.del   = 0.05;  %Depreciation Rate
param.alph  = 0.36;  %Capital Share (never call anything alpha, either)
param.rho   = 0.9;   %Autocorrelation of productivity shocks
param.gam   = 1;
param.sigma = 1;
