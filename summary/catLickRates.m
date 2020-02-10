function B = catLickRates( B, lickRates, expIdx )

cellType = fieldnames(expIdx);  %Eg, {'all','SST'}
pre_post = {'preCue','postCue'};
for i = 1:numel(cellType)
    idx = (expIdx.(cellType{i})); %Session idx, pooled and cell type-specific
    for j = 1:numel(pre_post)
        fields = fieldnames(lickRates.(pre_post{j}));
        for k = 1:numel(fields)
             B.(cellType{i}).lickRates.(pre_post{j}).(fields{k})(idx,:) = ... %Enforce column vector
                 lickRates.(pre_post{j}).(fields{k}); %Lick rates pre- & post-cue, for comparing, eg, pre-cue lick rate in sound vs action.
        end
    end
end