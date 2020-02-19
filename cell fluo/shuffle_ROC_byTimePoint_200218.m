%% shuffle_ROC()
%
% PURPOSE: To calculate the empirical receiver operating characteristic.
% AUTHOR: MJ Siniscalchi, 190924
%
% INPUT ARGS:
%       signal: Numeric vector of predictor values (ie, replicates from aligned timeseries data) 
%       class_label: Integer vector of true class labels corresponding to each element of 'signal' 
%       positive_class: Integer specifying the positive class label.
%       params.nShuffle: Number of shuffled replicates
%
% OUTPUTS:
%       AUC: The area under the ROC curve, ie under plot(fpr,tpr), for each
%           shuffled replicate of the data.
%--------------------------------------------------------------------------

function [ TPR, FPR, AUC ] = shuffle_ROC( signal, class, positive_class, params )

% Initialize
nUnique = numel(unique(signal)); %Each unique value is used as a threshold in roc()
AUC = NaN(params.nShuffle,1);
tpr = NaN(nUnique,params.nShuffle);
fpr = NaN(nUnique,params.nShuffle);

for i = 1:params.nShuffle  
    %Shuffle class labels
    class = class(randperm(numel(class)));
    %Calculate empirical receiver operating characteristic
    [tpr(:,i),fpr(:,i),AUC(i)] = roc(signal,class,positive_class);
end
TPR = mean(tpr,2);
FPR = mean(fpr,2);
