function B = catSwitchPerf( B, trials, blocks, expIdx )

%Note: Window duration fixed based on minimum block length. 
%   If greater #trials desired post-switch, must modify struct blocks to exclude subset,
%   or use specialized coding for outcomes past firstTrial(i)+nTrials(i)

%Exclude last block if session aborted early
window = [-20 20]; %Window fixed based on minimum block length
nBlocks = numel(blocks.nTrials(blocks.nTrials>=window(2))); %Number of blocks

%Initialize data struct
rule = {'all','sound','action'};
outcome = {'hit','pErr','oErr','miss'};
for i = 1:numel(rule)
    for j = 1:numel(outcome)
        perf.(rule{i}).(outcome{j}) = NaN(nBlocks-1,diff(window)); %Performance array: size(nSwitches,nSwitchTrials)
    end
end

%Populate each row of outcome arrays with logical idxs for corresponding trials
blocks.type(ismember(blocks.type,{'actionL','actionR'})) = {'action'};
for i = 1:nBlocks-1
    trialIdx = blocks.firstTrial(i+1)+window(1):blocks.firstTrial(i+1)+window(2)-1;
    for j = 1:numel(outcome)
        perf.all.(outcome{j})(i,:) = trials.(outcome{j})(trialIdx);
        perf.(blocks.type{i+1}).(outcome{j})(i,:) = trials.(outcome{j})(trialIdx); %Referenced by next block, eg A->S found in field 'sound'
    end
end

% Outcome density for each trial relative to switch
cellType = fieldnames(expIdx);
for i =1:numel(cellType)
    for j = 1:numel(rule)
        for k = 1:numel(outcome)
            B.(cellType{i}).perfCurve.(rule{j}).(outcome{k})(expIdx.(cellType{i}),:) = ...
                nanmean(perf.(rule{j}).(outcome{k})); %Performance array: size(nSwitches,nSwitchTrials)
        end
    end
end