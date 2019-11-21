function B = catBlockStats( B, blocks, expIdx )

%Index the relevant rule blocks
excl = [true; false(numel(blocks.type)-2,1); true]; %Exclude first and last block
blkIdx.sound = strcmp(blocks.type,'sound') & ~excl;
blkIdx.action = ismember(blocks.type,{'actionL','actionR'}) & ~excl;

rule = fieldnames(blkIdx);
cellType = fieldnames(expIdx);  %Eg, {'all','SST'}
for i = 1:numel(rule)
    for j = 1:numel(cellType)
        idx = (expIdx.(cellType{j})); %Session idx, pooled and cell type-specific
        %Trials to criterion
        B.(cellType{j}).trials2crit.(rule{i})(idx,:) = median(blocks.nTrials(blkIdx.(rule{i})));
        %Perseverative errors
        B.(cellType{j}).pErr.(rule{i})(idx,:) = median(blocks.pErr(blkIdx.(rule{i})));
        %Other errors
        B.(cellType{j}).oErr.(rule{i})(idx,:) = median(blocks.oErr(blkIdx.(rule{i})));
    end
end

