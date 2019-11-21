function T = calc_transitionResults( img_beh, params )

nCells = numel(img_beh.trialDFF.cueTimes);
nTrans = numel(img_beh.blocks.type)-2; %Exclude first and last block (no transition in either case)
timeIdx = img_beh.trialDFF.t>params.window(1) & img_beh.trialDFF.t<=params.window(2);

%Initialize struct
T.type = cell(1,nTrans); 
T.firstTrial = img_beh.blocks.firstTrial(2:end-1);
T.nTrials = img_beh.blocks.nTrials(2:end-1);
T.meanDFF  = cell(1,nTrans); 
T.medianDFF  = cell(1,nTrans);
T.cellID = img_beh.cellID;
T.sessionID = img_beh.sessionID;

for i = 1:nTrans   
    T.type{i} = [img_beh.blocks.type{i} '_' img_beh.blocks.type{i+1}]; %Named as 'priorBlock_currentBlock'
    trialIdx = getBlockMask(i+1,img_beh.blocks); %Current block idx == i+1
    %Generate matrix of size [nCells,nTrials] containing mean dFF
    for j = 1:nCells
        T.meanDFF{i}(j,:) = mean(img_beh.trialDFF.cueTimes{j}(trialIdx,timeIdx),2);
        T.medianDFF{i}(j,:) = median(img_beh.trialDFF.cueTimes{j}(trialIdx,timeIdx),2);
    end
end

