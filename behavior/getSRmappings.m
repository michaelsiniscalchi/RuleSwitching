function [ SR ] = getSRmappings( blockSeq )
%%% getSRmappings() %%%
%PURPOSE: Retrieve contingencies for each block of the RuleSwitching task.
%AUTHOR: MJ Siniscalchi 161215.
%--------------------------------------------------------------------------
%
%INPUT ARGUMENTS
%   blockSeq:= Cell array of strings indicating sequence of rule blocks.
%OUTPUT VARIABLES
%   SR:= Struct containing these fields, characterizing
%           stimulus-response-trialType structure of each rule block:
%
%--------------------------------------------------------------------------
nBlocks = numel(blockSeq);
type = {'sound' 'actionL' 'actionR'};

SR.mapping = cell(1,nBlocks);
for i = 1:numel(type)
    switch type{i}
        case 'sound'
            tempCell = {'upsweep' 'downsweep'; 'left' 'right'}; %should be fieldnames for getTrialMasks
        case 'actionL'
            tempCell = {'upsweep' 'downsweep'; 'left' 'left'};
        case 'actionR'
            tempCell = {'upsweep' 'downsweep'; 'right' 'right'};
    end
    blockMask = strcmp(blockSeq,type{i});    %Blocks in the sequence matching type{i}
    SR.mapping(blockMask) = {tempCell};      %Populate with {contingency strings}
end

end