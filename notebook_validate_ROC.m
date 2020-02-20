load('J:\Data & Analysis\Rule Switching\Results\170929 M48 RuleSwitching_DEVO\results.mat', 'decode')
% load('J:\Data & Analysis\Rule Switching\Results\171103 M47 RuleSwitching_DEVO\results.mat', 'decode')

setup_figprops('timeseries');
nShuffle = size(decode.outcome.AUC_shuffle{1},1);

% figure;
%
% X = repmat(decode.t,nShuffle,1);
% for i=1:nShuffle
%     line(X,max(decode.outcome.AUC_shuffle{1},[],i),'Color',[0.5 0.5 0.5]); hold on;
% end

i=3;
shuffle_hi = prctile(decode.outcome.AUC_shuffle{i},95);
shuffle_lo = prctile(decode.outcome.AUC_shuffle{i},5);

figure;
errorshade(decode.t,shuffle_lo,shuffle_hi,'k',0.2); hold on;
plot(decode.t,decode.outcome.AUC{i},'r');

for j = 1:nShuffle
    nullRep = decode.outcome.AUC_shuffle{i}(j,:);
    shuffle_hi = prctile(decode.outcome.AUC_shuffle{i},95);
    shuffle_lo = prctile(decode.outcome.AUC_shuffle{i},5);
    for t=1:numel(decode.t)
    
    end
    
end

% Construct function to test each shuffle....
 sig_bins = false(size(sel_idx)); %Initialize logical array for significant time bins 
    for i = 1:size(sel_idx,1) %For each cell
        %Estimate CI for null distribution
        shuffle = 2*(decode.(decodeType).AUC_shuffle{i}-0.5); %Obtain selectivity from shuffled AUC
        CI_low = prctile(shuffle,50-params.CI/2,1);
        CI_high = prctile(shuffle,50+params.CI/2,1);
        %Compare selectivity idx to CI to find significant bins
        sig_bins(i,:) = (sel_idx(i,:)<CI_low | sel_idx(i,:)>CI_high);
    end
    test_mat = sig_bins(:,post_t0); %Only include bins starting at t0
end

nConsec = params.sig_duration/mean(diff(decode.t)); %Significance threshold: consecutive bins above chance
for j = 1:size(sel_idx,1) %For each cell
    isSelective(j,:) = testConsecTrue(test_mat(j,:),nConsec); %#ok<AGROW>
end