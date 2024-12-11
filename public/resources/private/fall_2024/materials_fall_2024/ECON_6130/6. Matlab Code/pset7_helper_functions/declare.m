% DECLARE - generate symbolic variables and a vector of the same
%
% usage:
%
% declare  X Y Z
%
% creates a vector of symbolic variables V = [X,Y,Z] and individual
% symbolic variables in X Y Z in the calling workspace
%
% Ryan Chahrour
% Cornell University
% 2023

function D = declare(varargin)

D = sym(zeros(1,length(varargin)));
for jj = 1:length(varargin)   
    str = varargin{jj};   
    D(jj) = sym(str);
    assignin('caller', str, D(jj));
end
assignin('caller', 'D', D);