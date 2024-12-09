%Pack a vector of coefficients into the layers with bias and weights of the
%neural network.
function [bias,weights] = nn_pack(coeff0,nh)

nlayer = length(nh);
bias   = cell(1,nlayer-1); weights =cell(1,nlayer-1);
ctr_start = 1;
for ii = 1:nlayer-1
    bias{ii}    = zeros(nh(ii+1),1);
    weights{ii} = zeros(nh(ii+1),nh(ii));

    ctr_end = ctr_start+nh(ii+1)-1;
    bias{ii}(:) = coeff0(ctr_start:ctr_end);

    ctr_start = ctr_end+1;
    ctr_end   = ctr_start + nh(ii)*nh(ii+1)-1;
    weights{ii}(:) = coeff0(ctr_start:ctr_end);

    ctr_start = ctr_end+1;
end
