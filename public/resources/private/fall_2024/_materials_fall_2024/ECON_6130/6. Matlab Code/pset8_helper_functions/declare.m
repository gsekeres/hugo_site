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

function V = declare(varargin)

V = sym(zeros(1,length(varargin)));
for jj = 1:length(varargin)   
    str = varargin{jj};   
    V(jj) = sym(str);
    assignin('caller', str, V(jj));
end
assignin('caller', 'V', V);