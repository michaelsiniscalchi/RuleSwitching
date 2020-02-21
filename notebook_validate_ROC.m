% This code was used to develop the function 
%   [selIdxNull_cells_t, pSigNull_cells_t, pNull] = get_nullSelectivity(decode, decodeType, params);
%
% NOTE: t0 is now set in the params (here, we assume the entire trial was used...
%
%---------------------------------------------------------------------------------------------------

% Load Data
expIdx = 1;
cellIdx=1;
load(mat_file.results(expIdx), 'decode');

% Set Figure Properties
setup_figprops('timeseries');
fig = figure;
fig.Position = [150 100 800 600];

% Extract Specified Data
auc = decode.outcome.AUC{cellIdx};
shuffle = decode.outcome.AUC_shuffle{cellIdx};
[sigBins, isNull] = testNullSelectivity(shuffle, decode.t, params.decode);

errorshade(decode.t,shuffle_lo,shuffle_hi,'k',0.2); hold on;
for j = find(isNull)'
    plot(decode.t,shuffle(j,:),'k','LineWidth',1);
end
plot(decode.t,auc,'r');

disp(mean(isNull));


%% Construct function to test each shuffle....
function [sigBins, isNull] = testNullSelectivity( auc_shuffle, time, params )

%Estimate CI for null distribution
shuffle = 2*(auc_shuffle-0.5); %Obtain selectivity (range: -1,1) from shuffled AUC
CI_low = prctile(shuffle,50-params.CI/2,1);
CI_high = prctile(shuffle,50+params.CI/2,1);

sigBins = false(size(shuffle)); %Initialize logical array for significant time bins
for i = 1:size(shuffle,1) %For each shuffle
    %Compare selectivity idx to CI to find significant bins
    sigBins(i,:) = (shuffle(i,:)<CI_low | shuffle(i,:)>CI_high);
end
% test_mat = sig_bins(:,post_t0); %Only include bins starting at t0 

nConsec = params.sig_duration/mean(diff(time)); %Significance threshold: consecutive bins above chance
for j = 1:size(shuffle,1) %For each cell
    isNull(j,:) = testConsecTrue(sigBins(j,:),nConsec); %#ok<AGROW>
end
end