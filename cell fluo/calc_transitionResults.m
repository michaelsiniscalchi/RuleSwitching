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
origin_dest(nTrans,1)       = struct('R',[],'Rho',[],'Cs',[]);                      %Similarity between origin and destination
similarity(nTrans,1)        = struct('values',[],'binValues',[],'trialIdx',[],'binIdx',[],'changePt1',[],'changePtsN',[]);    %Similarity(dest) - Similarity(origin)
behChangePt1                = nan(numel(type),1); %Initialize
behChangePt2                = nan(numel(type),1); %Initialize

%% Estimate Similarity of Each Per-Trial Activity Vector to Mean for Prior and Current Rule
for i = 1:nTrans
       
    % Calculate population activity vector for prior rule
    type{i} = [img_beh.blocks.type{i} '_' img_beh.blocks.type{i+1}]; %Named as 'priorBlock_currentBlock'
    trialIdx = getBlockMask(i,img_beh.blocks); %Logical indices for all trials in prior block
    [trialVectorsPreSwitch, origin(i).vector] = ... %Average dF/F for each cell across specified number of trials prior to last switch (Prior rule)
        timeAvgDFF( trialDFF, trialIdx, timeIdx, nTrialsPreSwitch );
    
    trialVectorsPreSwitch = trialVectorsPreSwitch(:,end-nTrialsPreSwitch+1:end); %Keep only the trial vectors within the averaging frame pre-switch
    
    % Calculate population activity vector for current rule
    trialIdx = getBlockMask(i+1,img_beh.blocks); %Logical indices for all trials in current block
    [trialVectorsPostSwitch, destination(i).vector] = ... %Average dF/F for each cell across specified number of trials prior to next switch (Current rule)
        timeAvgDFF( trialDFF, trialIdx, timeIdx, nTrialsPreSwitch );
    
    % Correlation with population vector for prior and current rules
    trialVectors{i} = [trialVectorsPreSwitch, trialVectorsPostSwitch];
    origin(i).similarity = calcSimilarity( origin(i).vector, trialVectors{i});
    destination(i).similarity = calcSimilarity( destination(i).vector, trialVectors{i});
    
    % Correlation between origin and destination vectors
    origin_dest(i) = calcSimilarity( origin(i).vector, destination(i).vector);
   
end

%% COMPARE SIMILARITY TO ORIGIN AND DESTINATION

% Difference Between Dest and Origin
P = 1/params.nBins:1/params.nBins:1; %N evenly spaced quantiles for trial indices
for i = 1:numel(type)
    
    dest = destination(i).similarity.(params.stat);
    orig = origin(i).similarity.(params.stat);
    values = (dest-orig); %Difference in similarity measures for each trial in i-th block
    trialIdx = -nTrialsPreSwitch : numel(values)-nTrialsPreSwitch-1; %Number of trials from rule switch; trialIdx==0 is the first trial post-switch
    
    %Average postswitch results within evenly spaced bins 
    switchTrial = find(trialIdx==0);
    edges = [switchTrial round(quantile(switchTrial:numel(values),P))]; 
    [~,~,bin] = histcounts(1:numel(values),edges); %Get ordinal indices 
    for j = unique(bin(bin>0)) %bin==0 indexes preswitch trials
        bins_post(j) = mean(values(bin==j));  %#ok<AGROW>
    end
     
    %Average within last bin preswitch
    idx = switchTrial-min(mode(diff(edges)),nTrialsPreSwitch); %Use length of avg. bin post-switch <= nTrialsPreSwitch
    idx = idx:switchTrial-1; %Trial indices for last bin
    bins_pre = mean(values(idx));  
    binValues = [bins_pre, bins_post]; %Binned average difference
    binIdx = [-numel(bins_pre):-1, 1:numel(bins_post)]; %Bin indices; preswitch bin(s) coded negative, postwitch positive
    
    %Find Change-Point(s) Post Switch
    idx = nTrialsPreSwitch+1 : numel(values); %Minimize RSS for step function
    changePt1 = findchangepts(values(idx)); %Number of trials from rule switch; same as find(ischange(values(idx),'MaxNumChanges',1))
    changePtsN = find(ischange(values(idx))); 
        
    %Populate structure array
    similarity(i) = loadStruct(values,trialIdx,binValues,binIdx,changePt1,changePtsN);

end

% Aggregate rule type specific transitions
soundIdx            = ismember(type,{'actionL_sound','actionR_sound'});
actionIdx           = ismember(type,{'sound_actionL','sound_actionR'});
aggregate.all       = cell2mat({similarity.binValues}');
aggregate.sound     = cell2mat({similarity(soundIdx).binValues}');
aggregate.action    = cell2mat({similarity(actionIdx).binValues}');
aggregate.idx       = similarity(1).binIdx;

%% Change points for behavioral transitions

% nTrials in each transition block
transIdx = 2:numel(img_beh.blocks.firstTrial)-1; %Index transition blocks: 2:end-1
firstTrial = img_beh.blocks.firstTrial(transIdx);
nTrials = img_beh.blocks.nTrials(transIdx); 
outcome = double(img_beh.trials.hit);

for i = 1:numel(type)
    idx = firstTrial(i) : firstTrial(i)+nTrials(i)-1; %Index only trials in current block
    %MATLAB function
    behChangePt1(i) = findchangepts(outcome(idx)); % Does not seem to work as well
    %Cumulative sum of deviations from mean
    cumDev = cumsum(outcome(idx)-mean(outcome(idx))); 
    chgpt = find(cumDev==min(cumDev));
    if numel(chgpt)==1
        behChangePt2(i) = chgpt;
    end
end

%% Store results in structure

sessionID = img_beh.sessionID;
T = loadStruct(sessionID, type, cellID, origin, destination, origin_dest,...
    trialVectors, similarity, aggregate, behChangePt1, behChangePt2, nTrials, params);

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