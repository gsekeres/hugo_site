function [coeff1,bias,weights,np] = nn_unpack(coeff0,nh,nh_new)

nlayer = length(nh);
bias   = cell(1,nlayer-1); weights =cell(1,nlayer-1);
ctr_start = 1;
coeff1 = [];
for ii = 1:nlayer-1
    bias{ii}    = ones(nh_new(ii+1),1)*(ii<(nlayer-1));
    weights{ii} = ones(nh_new(ii+1),nh_new(ii))*(ii<(nlayer-1));

    ctr_end = ctr_start+nh(ii+1)-1;
    bias{ii}(1:nh(ii+1)) = coeff0(ctr_start:ctr_end);

    coeff1 = [coeff1;vec(bias{ii})];

    ctr_start = ctr_end+1;
    ctr_end   = ctr_start + nh(ii)*nh(ii+1)-1;
    weights{ii}(1:nh(ii+1),1:nh(ii)) = reshape(coeff0(ctr_start:ctr_end),[nh(ii+1),nh(ii)]);
    coeff1 = [coeff1;vec(weights{ii})];
   
    ctr_start = ctr_end+1;
end

np = size(coeff1);
