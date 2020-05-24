function B = catLickRates( B, lickRates, lickDiffs, expIdx )

cellType = fieldnames(expIdx);  %Eg, {'all','SST'}
pre_post = {'preCue','postCue'};
cue = {'upsweep','downsweep'};

% Lick Rates pre/post-cue for various trial subsets
for i = 1:numel(cellType)
    idx = (expIdx.(cellType{i})); %Session idx, pooled and cell type-specific
    for j = 1:numel(pre_post)
        fields = fieldnames(lickRates.(pre_post{j}));
        fields = fields(~ismember(fields,cue)); %'upsweep' and 'downsweep' are structs 
        for k = 1:numel(fields)
             B.(cellType{i}).lickRates.(pre_post{j}).(fields{k})(idx,:) = ... %Enforce column vector
                 lickRates.(pre_post{j}).(fields{k}); %Lick rates pre- & post-cue, for comparing, eg, pre-cue lick rate in sound vs action.
        end
    end
end

% Lick Rates for Upsweep and Downsweep trials in each Rule
rule = {'sound','actionL','actionR'};
for i = 1:numel(cellType)
    idx = (expIdx.(cellType{i})); %Session idx, pooled and cell type-specific
    for j = 1:numel(cue)
        for k = 1:numel(rule)
            B.(cellType{i}).lickRates.postCue.(cue{j}).(rule{k})(idx,:) = ... %Enforce column vector
                lickRates.postCue.(cue{j}).(rule{k}); %Lick rates post-cue
        end
    end
end

% Differences in Left vs Right Lick Rates
cue = {'upsweep','downsweep','all'};
for i = 1:numel(cellType)
    idx = (expIdx.(cellType{i})); %Session idx, pooled and cell type-specific
    for j = 1:numel(pre_post)
        for k = 1:numel(cue)
            for kk = 1:numel(rule)
             B.(cellType{i}).lickDiffs.(pre_post{j}).(cue{k}).(rule{kk})(idx,:) = ... %Enforce column vector
                 lickDiffs.(pre_post{j}).(cue{k}).(rule{kk}); 
            end
        end
    end
end
