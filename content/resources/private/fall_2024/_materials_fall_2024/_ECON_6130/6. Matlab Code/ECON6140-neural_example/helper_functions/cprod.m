%CPROD - Multyply and sum the columns of a matrix

function out = cprod(xin)

out = zeros(size(xin,1),1);
for jj = 1:(size(xin,2)-1)

    out = out + xin(:,jj).*xin(:,jj+1);
end