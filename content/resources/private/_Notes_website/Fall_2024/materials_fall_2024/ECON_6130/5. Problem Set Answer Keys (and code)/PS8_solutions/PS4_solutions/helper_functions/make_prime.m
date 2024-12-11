%MAKE_PRIME - For any symoblic vector, return a vector with symoblic
%elements of the same names with a _p suffix.
%
%
% usage (by example)
%
% out = make_prime([X1 X2])
%
% out = 
%       [X1_p X2_p]

function Vp = make_prime(V)

Vp = sym('Vp', size(V));

if numel(V) ==0
    Vp = [];
    return;
end


for j = 1:numel(V)
    str = [char(V(j)), '_p'];
    Vp(j) = sym(str);
    assignin('caller', str, Vp(j));
end

