%% A simple neural network evaluation
% 
% usage
% 
% lout = nn_eval(xin,nh,bias,weights,a)
%
% where
%
% xin = [nx,nt] input data series, nx variables, nt observations
% nh  = is a vector of the dimension of each layer, intial and final inclusive. 
% bias = cellarray with constant paramteters for the length(nh)-1 layers
% wegihts = cellarray with with the weights for the legnth(nh)-1 layers;

function l_out = nn_eval(xin,nh,bias,weights,a,varargin)

nlayer = length(nh)-1;
if length(a)~=nlayer
    error(['Neutral network with ' num2str(nlayer) ' layers, but ' num2str(length(a)) ' activation functions.']);
end

nobs  = size(xin,2);

%%Pretreat the data
if ~isempty(varargin)>0
   %standardize the input data
   xin = (xin - varargin{1}.mean)./varargin{1}.std;
end

%% Main evaulation
l_in = xin;
for jj = 1:nlayer

    %Nodes in and out
    nin  = nh(jj);
    nout = nh(jj+1);

    if nin ~= size(weights{jj},2)
        error(['Conformability problem on inputs in layer' num2str(jj)]);
    end

    if nout ~= size(weights{jj},1)
        error(['Conformability problem on output in layer' num2str(jj)]);
    end


    %Compute the first hiden layer input
    l1     = bias{jj} + weights{jj}*l_in;

    %Activate
    l_out = a{jj}(l1);

    %Send on to the next layer.
    l_in = l_out;  
end

%%Post-treat the data
if length(varargin)>1
   %standardize the output data
   l_out = l_out.*varargin{2}.std + varargin{2}.mean;
end








