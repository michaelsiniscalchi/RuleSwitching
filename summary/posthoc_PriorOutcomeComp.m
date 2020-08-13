%[fieldnames(compStruct)]' = ...
% {'varName'} {'comparison'} {'diff'} {'p'} {'N'} {'testName'} {'stats'}

% % Secondary comparison: difference in *corrected* means between cell-types
%     [compStruct, stats] = addComparison(...
%         compStruct,S,{decodeTypes(i),cellTypes,"diffNull","selIdx"},test.cellTypes); %Report mean & sem
%     Post-hoc test
%     if str2double(compStruct(end).p)<alpha
%         mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName);
%     end


newComp = struct('varName','comparison','diff','p','N','testName','stats');
idx = S.time<0; %Pre-cue times
for i=1:numel(cellTypes)
    data.(cellTypes(i)) = mean(S.prior_outcome.(cellTypes(i)).diffNull.selMag_t.data(:,idx),2);
end