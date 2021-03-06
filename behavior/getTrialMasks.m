function [ trials ] = getTrialMasks( sessionData, trialData, blocks )
% % getTrialMasks %
%PURPOSE:   Create data structure, 'trials', containing logical masks
%           of size(nTrials,1) for task variables.
%AUTHORS:   MJ Siniscalchi 161214.
%           modified by:    AC Kwan 170515
%                           MJ Siniscalchi 190701
%
%INPUT ARGUMENTS
%   trialData:  Structure generated by getSessionData()
%   blocks:     Structure generated by getBlockData()
%
%OUTPUT VARIABLES
%   trials:     Structure containing these fields, each a logical mask
%               indicating whether trial(idx) is of the corresponding subset, e.g.,
%               response==left or cue==upsweep.

%%
nTrials = numel(trialData.outcomeTimes);

%% GET CODES FROM PRESENTATION
[STIM,RESP,OUTCOME,EVENT] = getPresentationCodes(1);

%% GET LOGICAL MASKS FOR TRIALS WITH DISTINCT CHOICES, OUTCOMES, AND RULES
taskVar = {'cue' 'response' 'outcome' 'rule'};

for i = 1:numel(taskVar)
    clear codes;
    switch taskVar{i}
        case 'cue'
            codes.upsweep = [STIM.sound_UPSWEEP,...
                STIM.left_UPSWEEP,...
                STIM.right_UPSWEEP];
            codes.downsweep = [STIM.sound_DNSWEEP,...
                STIM.left_DNSWEEP,...
                STIM.right_DNSWEEP];
        case 'response'
            codes.left = [RESP.LEFT];
            codes.right = [RESP.RIGHT];
        case 'outcome'
            codes.hit =...
                [OUTCOME.REWARDLEFT,...
                OUTCOME.REWARDRIGHT];
            codes.err = [OUTCOME.NOREWARD];
            codes.miss = [OUTCOME.MISS];
        case 'rule'
            codes.sound   =...
                [STIM.sound_UPSWEEP,...
                STIM.sound_DNSWEEP];
            codes.action  =...
                [STIM.left_UPSWEEP,...
                STIM.left_DNSWEEP,...
                STIM.right_UPSWEEP,...
                STIM.right_DNSWEEP];
            codes.actionL =...
                [STIM.left_UPSWEEP,...
                STIM.left_DNSWEEP];
            codes.actionR =...
                [STIM.right_UPSWEEP,...
                STIM.right_DNSWEEP];
            trialData.rule = trialData.cue; %Rule info is multiplexed in presentation codes for cue
    end
    fields = fieldnames(codes);
    for j = 1:numel(fields)
        trials.(fields{j}) = ismember(trialData.(taskVar{i}),codes.(fields{j})); %Generate trial mask for each field in 'codes'
    end
end

% Trials Performed: All trials in which a response was registered
trials.performed = ~trials.miss;

%% MASKS FOR PERSEVERATIVE AND OTHER ERRORS

trials.pChoice = false(nTrials,1);   %perseverative choices (both hits and errors)
trials.pErr = false(nTrials,1);    %perseverative errors
trials.oErr = false(nTrials,1);    %non-perseverative errors
SR = getSRmappings(blocks.type);
nBlocks = numel(blocks.type);

% In first block, classify all errors as other errors
blockMask = getBlockMask(1, blocks);   %trials corresponding to block 1
trials.oErr(trials.err & blockMask) = true;

% Beyond the first block
for i = 2:nBlocks
    
    %Find cue-response pairs consistent with prior block's rules
    tempMask=[];
    for j=1:2   % two mappings always (2 stim->resp contingencies)
        stimField = SR.mapping{i-1}{1,j};
        respField = SR.mapping{i-1}{2,j};
        tempMask(:,j) = trials.(stimField) & trials.(respField);
    end
    persevMask = tempMask(:,1) | tempMask(:,2);   %matches either of the past contingencies
    
    %find which trials belong to current block
    blockMask = getBlockMask(i, blocks);
    
    trials.pChoice(persevMask & blockMask) = true;
    trials.pErr(persevMask & trials.err & blockMask) = true;
    trials.oErr(~persevMask & trials.err & blockMask) = true;
    
end

%% MASK FOR TRIALS SURROUNDING RULE SWITCH

% Last 20 trials in block 
trials.last20 = false(nTrials,1);
for i = 2:nBlocks   %Exclude first block (not adaptive)
    trials.last20(blocks.firstTrial(i)-20:blocks.firstTrial(i)-1) = true;
end

% Transition trials: the 20 trials surrounding rule switch
trials.trans20 = false(nTrials,1);
for i = 2:nBlocks 
    trials.trans20(blocks.firstTrial(i)-10:blocks.firstTrial(i)+9) = true;
end

%% MASKS FOR PRIOR TRIAL TYPES

types = {'left','right','hit','err'};
for i=1:numel(types)
    trials.(['prior' upper(types{i}(1)) types{i}(2:end)]) = [false;trials.(types{i})(1:end-1)];
end

%% SPLIT RULE BLOCKS BY PRIOR RULE

trials.actionL_sound = false(nTrials,1);    %Sound trials, with prior action-left block
trials.actionR_sound = false(nTrials,1);    %Sound trials, with prior action-right block
trials.sound_actionL = false(nTrials,1);    %Action-left trials, with prior sound block
trials.sound_actionR = false(nTrials,1);    %Action-right trials, with prior sound block

for i = 2:nBlocks-1 %Exclude first and last block (no transition in either case)
    %Extract transition type
    transitionType = [blocks.type{i-1} '_' blocks.type{i}]; %Eg, 'sound_actionL'
    %Assign logical indices for trials within transition
    idx = blocks.firstTrial(i):blocks.firstTrial(i)+blocks.nTrials(i)-1;
    trials.(transitionType)(idx) = true;
end