function T = calc_transitionResults( img_beh, decode, params )

% Extract Data from Significantly Modulated Cells (or All)
if strcmp(params.cell_subset,'significant')
    [~,~,isSelective(1,:),~,~] = get_selectivityTraces(decode,'rule_SL',params);
    [~,~,isSelective(2,:),~,~] = get_selectivityTraces(decode,'rule_SR',params);
    cellMask = any(isSelective); %Identify cells modulated by rule in either left- or right-choice trials
elseif strcmp(params.cell_subset,'all')
    cellMask = true(numel(img_beh.cellID),1);
end

trialDFF = img_beh.trialDFF.cueTimes(cellMask);
cellID = img_beh.cellID(cellMask);

% Units of Measure and Time Index
nTrans = numel(img_beh.blocks.type)-2; %Exclude first and last block (no transition in either case)
nTrialsPreSwitch = params.nTrialsPreSwitch;
timeIdx = img_beh.trialDFF.t>params.window(1) & img_beh.trialDFF.t<=params.window(2);

% Initialize arrays
type                        = cell(nTrans,1);
trialVectors                = cell(nTrans,1);
origin(nTrans,1)            = struct('vector',[],'similarity',struct('R',[],'Rho',[],'Cs',[])); %Population vector averaged over nTrials pre-switch; calculate trial-by-trial similarity to this vector
destination(nTrans,1)       = struct('vector',[],'similarity',struct('R',[],'Rho',[],'Cs',[])); %Same for destination vector
similarity(nTrans,1)    = struct('trials',[],'trialIdx',[],'bins','binIdx'); %Similarity(dest) - Similarity(origin)

%% Estimate Similarity of Each Per-Trial Activity Vector to Mean for Prior and Current Rule
for i = 1:nTrans
    
    type{i} = [img_beh.blocks.type{i} '_' img_beh.blocks.type{i+1}]; %Named as 'priorBlock_currentBlock'
    
    %Calculate population activity vector for prior rule
    trialIdx = getBlockMask(i,img_beh.blocks); %Logical indices for all trials in prior block
    [trialVectorsPreSwitch, origin(i).vector] = ... %Average dF/F for each cell across specified number of trials prior to last switch (Prior rule)
        timeAvgDFF( trialDFF, trialIdx, timeIdx, nTrialsPreSwitch );
    
    trialVectorsPreSwitch = trialVectorsPreSwitch(:,end-nTrialsPreSwitch+1:end); %Keep only the trial vectors within the averaging frame pre-switch
    
    %Calculate population activity vector for current rule
    trialIdx = getBlockMask(i+1,img_beh.blocks); %Logical indices for all trials in current block
    [trialVectorsPostSwitch, destination(i).vector] = ... %Average dF/F for each cell across specified number of trials prior to next switch (Current rule)
        timeAvgDFF( trialDFF, trialIdx, timeIdx, nTrialsPreSwitch );
    
    %Correlation with population vector for prior and current rules
    trialVectors{i} = [trialVectorsPreSwitch, trialVectorsPostSwitch];
    origin(i).similarity = calcSimilarity( origin(i).vector, trialVectors{i});
    destination(i).similarity = calcSimilarity( destination(i).vector, trialVectors{i});
    
end

%% COMPARE SIMILARITY TO ORIGIN AND DESTINATION

% Difference Between Dest and Origin
P = 1/params.nBins:1/params.nBins:1; %N evenly spaced quantiles for trial indices
for i = 1:numel(type)
    
    dest = destination(i).similarity.(params.stat);
    orig = origin(i).similarity.(params.stat);
    values = (dest-orig); %Note that distance rather than similarity was used in NatNeuro study...
    trialIdx = -params.nTrialsPreSwitch : numel(values)-params.nTrialsPreSwitch-1; %trialIdx==0 is the first trial post-switch
    
    %Average postswitch results within evenly spaced bins 
    switchTrial = find(trialIdx==0);
    edges = [switchTrial round(quantile(switchTrial:numel(values),P))]; 
    [~,~,bin] = histcounts(1:numel(values),edges); %Get ordinal indices 
    for j = unique(bin(bin>0)) %bin==0 indexes preswitch trials
        bins_post(j) = mean(values(bin==j));  %#ok<AGROW>
    end
     
    %Average within last bin preswitch
    idx = switchTrial-min(mode(diff(edges)),params.nTrialsPreSwitch); %Length of avg. bin post-switch up to nTrialsPreSwitch
    idx = idx:switchTrial-1; %Trial indices for last bin
    bins_pre = mean(values(idx));
    
    %Concatenate and index        
    similarity(i).bins = [bins_pre, bins_post]; %Binned average difference
    similarity(i).binIdx = [-numel(bins_pre):-1, 1:numel(bins_post)]; %Binned average difference
    similarity(i).trials = values; %Difference in similarity measures for each trial in i-th block
    similarity(i).trialIdx = trialIdx; %Number of trials from rule switch
end

% Aggregate rule type specific transitions
soundIdx            = ismember(type,{'actionL_sound','actionR_sound'});
actionIdx           = ismember(type,{'sound_actionL','sound_actionR'});
aggregate.all       = cell2mat({similarity.bins}');
aggregate.sound     = cell2mat({similarity(soundIdx).bins}');
aggregate.action    = cell2mat({similarity(actionIdx).bins}');
aggregate.idx       = similarity(1).binIdx;

%% Store results in structure

sessionID = img_beh.sessionID;
T = loadStruct(sessionID,cellID,type,origin,destination,trialVectors,similarity,aggregate,params);

%% ------- Internal Functions ----------------------------------------------------------------------

function [ trialDFF, ruleDFF ] = timeAvgDFF( cellDFF, trialIdx, timeIdx, nTrialsPreSwitch )

%Generate matrix of size [nCells,nTrials] containing mean dFF from each trial
nCells = numel(cellDFF);
trialDFF = NaN(numel(cellDFF),sum(trialIdx)); %Initialize
for j = 1:nCells
    trialDFF(j,:) = mean(cellDFF{j}(trialIdx,timeIdx),2); %Average over time for each trial
end

%Average over specified number of trials pre-switch
trialIdx = sum(trialIdx)-nTrialsPreSwitch+1 : sum(trialIdx); %Specified subset of trials
ruleDFF = mean(trialDFF(:,trialIdx),2);

%---------------------------------------------------------------------------------------------------
function S = calcSimilarity( ruleVector, trialVectors )

%Pearson's R
R = corrcoef([ruleVector,trialVectors]);
S.R = R(2:end,1); %Restrict comparisons to n-th trial vector vs. rule vector

%Spearman's Rho
Rho = corr([ruleVector,trialVectors],'Type','Spearman');
S.Rho = Rho(2:end,1); %Restrict comparisons to n-th trial vector vs. rule vector

%Cosine Similarity: Dot product divided by product of vector magnitudes
for ii = 1:size(trialVectors,2)
    S.Cs(ii,:) =  dot(ruleVector,trialVectors(:,ii)) ./...
        (norm(ruleVector).*norm(trialVectors(:,ii)));
end

%---------------------------------------------------------------------------------------------------
function S = loadStruct(varargin)
for ii = 1:numel(varargin)
    S.(inputname(ii)) = varargin{ii};
end