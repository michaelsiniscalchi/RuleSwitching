
function [ selIdxNull_cells_t, pSigNull_cells_t, pNull] = get_nullSelectivity( decode, time, params )

%% INITIALIZE
nCells = size(decode.AUC_shuffle,1);
selIdxNull_cells_t  = NaN(nCells,numel(time));
pSigNull_cells_t    = NaN(nCells,numel(time));
pNull               = NaN(nCells,1);

%% CALCULATE FALSE DISCOVERY RATES

for i = 1:nCells

    %Calculate chance-level selectivity index for each cell as a function of time
    shuffle = 2*(decode.AUC_shuffle{i}-0.5); %Obtain selectivity (range: -1,1) from shuffled AUC
    selIdxNull_cells_t(i,:) = mean(shuffle);
    
    %Calculate false discovery rates across all shuffled replicates of AUC
    [sigBins, isNull] = testNullSelectivity(shuffle, time, params); %Significant bins in each shuffle and idx of overall significant shuffles
    pSigNull_cells_t(i,:) = mean(sigBins,1); %Chance-level probability for each time bin
    pNull(i) = mean(isNull); %Probability of finding cell(i) significant by chance
    
end

%% -------INTERNAL FUNCTIONS------------------------------------------------------------------------

function [sig_bins, isNull] = testNullSelectivity( shuffle, time, params )

%Logical idx for post-trigger time bins
post_t0 = time>=params.t0;    

%Estimate CI for null distribution
CI_low = prctile(shuffle,50-params.CI/2,1);
CI_high = prctile(shuffle,50+params.CI/2,1);

sig_bins = false(size(shuffle)); %Initialize logical array for significant time bins
for i = 1:size(shuffle,1) %For each shuffle
    %Compare selectivity idx to CI to find significant bins
    sig_bins(i,:) = (shuffle(i,:)<CI_low | shuffle(i,:)>CI_high);
end
test_mat = sig_bins(:,post_t0); %Only include bins starting at t0

nConsec = params.sig_duration/mean(diff(time)); %Significance threshold: consecutive bins above chance
isNull = false(size(test_mat,1),1); %Initialize
for j = 1:size(test_mat,1) %For each cell
    isNull(j) = testConsecTrue(test_mat(j,:),nConsec); 
end