% PARAMETETRS - This function returns a parameter structure to use in the model solution.
% Object is used for easier passsing of many input values to function. 
%
% usage
%
% param = parameters
%
% (No input arguments, file is just for storing values and creating object)

function param = parameters()


param.bet  = 0.99;
param.sig  = 2.00;
param.alph = 0.30;
param.delk = 0.03;
param.deln = 0.10;
param.phin = 0.50;
param.chi  = 1.00;
param.veps = 0.25;
param.rho  = 0.95;
param.siga = 0.01;
