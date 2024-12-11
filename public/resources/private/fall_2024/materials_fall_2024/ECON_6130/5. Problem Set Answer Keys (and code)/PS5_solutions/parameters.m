% PARAMETETRS - This function returns a parameter structure to use in the model solution.
% Object is used for easier passsing of many input values to function. 
%
% usage
%
% param = parameters
%
% (No input arguments, file is just for storing values and creating object)

function param = parameters()


param.bet  = 0.98;  %Never call anything beta...it's a matlab function
param.gam  = 1.01;  %Average gross growth rate of TFP
param.chi  = 1;     %Disutility of labor
param.del  = 0.05;  %Depreciation Rate
param.alph = 0.36;  %Capital Share (never call anything alpha, either)
param.sige = 0.01;  %Standard deviation of TFP growth shocks


