function decode = decode_singleUnits( trial_dFF, trials, label, params )
tic 
% Unpack variables from structures
decode_idx = strcmp(params.label,label); %Find idx for the specified trialSpec, etc. 
trialSpec = params.trialSpec(decode_idx,:);
trial_dff = trial_dFF.cueTimes; %***FUTURE, could include arg 'trigger'

% Calculate trial-averaged dF/F
for i = 1:numel(trial_dff)
    disp(['Decoding ' params.label{decode_idx} ' from cell ' num2str(i) '/' num2str(numel(trial_dff)) '...']);  
    
    for j = 1:numel(trialSpec)
        subset_label = strjoin(trialSpec{j},'_');
        trialMask(:,j) = getMask(trials,trialSpec{j}); %Logical mask for specified combination of trials
    end
    
    subset = any(trialMask,2); %Try to generalize decodeTrialType
    dff = trial_dff{i}(subset,:); %Get only trials specified in trialMasks
    types = trialMask(subset,:);
    for t = 1:size(dff,2) %PARALLELIZE??
        %Decoding accuracy
        [accuracy{i}(t), AUC{i}(:,t)] =... %PRE-ALLOCATE
            decodeTrialType(dff(:,t),types);
        %Shuffle
        for j = 1:params.nShuffle
            idx = randperm(size(types,1));
            shuffled_types = types(idx,:);
            [acc_shuffled(j,t), ~] =...
                decodeTrialType(dff(:,t),shuffled_types); %decodeTrialType()
        end
    end
    shuffle{i}(1,:) = prctile(acc_shuffled, 50+params.CI/2, 1); %
    shuffle{i}(2,:) = prctile(acc_shuffled, 50-params.CI/2, 1);
end

% Store results in structure
decode.(params.label{1}).accuracy = accuracy;
decode.(params.label{1}).shuffle = shuffle;
decode.(params.label{1}).selectivity = cellfun(@(C) 2*(C-0.5), AUC, 'UniformOutput', false);
decode.t = trial_dFF.t;

toc

%  [AUC(j,:),decodeAcc(j)] = calc_ROC(dFF,trialType1,trialType2);
%     selIdx = 2*(AUC-0.5);
        