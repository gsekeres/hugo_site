%MAKE_LAG - For any symoblic vector, return a vector with symoblic
%elements of the same names with a _l suffix.
%
%
% usage (by example)
%
% out = make_prime([X1 X2])
%
% out = 
%       [X1_l X2_l]

function Vp = make_lag(V)

Vp = sym('Vp', size(V));

if numel(V) ==0
    Vp = [];
    return;
end


for j = 1:numel(V)
    str = [char(V(j)), '_l'];
    Vp(j) = sym(str);
    assignin('caller', str, Vp(j))
end

