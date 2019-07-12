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
[STIM,RESP,OUTCOME,EVENT] = getPresentationCodes(sessionData.presCodeSet);

%% GET MASKS FOR THOSE RESP/OUTCOME/RULE TYPES WITH CLEAR MAPPINGS
taskVar = {'cue' 'response' 'outcome' 'rule'};

for i = 1:numel(taskVar)
    clear codes;
    switch taskVar{i}
        case 'cue'
            codes.upsweep = [STIM.sound_UPSWEEP,...
                                STIM.left_UPSWEEP,...
                                STIM.right_UPSWEEP,...
                                STIM.reversal_UPSWEEP];
            codes.downsweep = [STIM.sound_DNSWEEP,...
                                STIM.left_DNSWEEP,...
                                STIM.right_DNSWEEP];
        case 'response'
            codes.left = [RESP.LEFT];
            codes.right = [RESP.RIGHT];
        case 'outcome'
            codes.hit = [OUTCOME.REWARDLEFT,...
                        OUTCOME.REWARDRIGHT];
            codes.err = [OUTCOME.NOREWARD];                        
            codes.miss = [OUTCOME.MISS];
        case 'rule'
            codes.sound   = [STIM.sound_UPSWEEP,...
                            STIM.sound_DNSWEEP];
            codes.actionL = [STIM.left_UPSWEEP,...
                            STIM.left_DNSWEEP];
            codes.actionR = [STIM.right_UPSWEEP,...
                            STIM.right_DNSWEEP];
                        
            trialData.rule = trialData.cue; %Rule info is multiplexed in presentation codes for cue
    end
    fields = fieldnames(codes);
    for j = 1:numel(fields)
        trials.(fields{j}) = ismember(trialData.(taskVar{i}),codes.(fields{j})); %Generate trial mask for each field in 'codes'
    end
end

%% GET MASKS FOR PERSEVERATIVE AND OTHER ERRORS
trials.pChoice = false(nTrials,1);   %perseverative choices (both hits and errors)
trials.pErr = false(nTrials,1);    %perseverative errors
trials.oErr = false(nTrials,1);    %non-perseverative errors
SR = getSRmappings(blocks.type);
nBlocks = numel(blocks.type);

%first block, classify all errors as other errors
blockMask = getBlockMask(1, blocks);   %trials corresponding to block 1
trials.oErr(trials.err & blockMask) = true;

%beyond the first block
for i = 2:nBlocks
    
    %find which cue-responses consistent with prior block's rules
    tempMask=[];
    for j=1:2   % two mappings always (2 stim->resp contingencies)
        stimField=SR.mapping{i-1}{1,j};
        respField=SR.mapping{i-1}{2,j};
        tempMask(:,j) = trials.(stimField) & trials.(respField);
    end
    persevMask=tempMask(:,1) | tempMask(:,2);   %matches either of the past contingencies
    
    %find which trials belong to current block
    blockMask = getBlockMask(i, blocks);
    
    trials.pChoice(persevMask & blockMask) = true;
    trials.pErr(persevMask & trials.err & blockMask) = true;
    trials.oErr(~persevMask & trials.err & blockMask) = true;
    
end

%% Mask for Last 20 Trials Pre-Switch 
trials.last20 = false(nTrials,1);   %perseverative choices (both hits and errors)
for i = 2:nBlocks
    trials.last20(blocks.firstTrial(i)-20:blocks.firstTrial(i)-1)=true;
end

%% Split Sound Trials by prior Action-L or Action-R

trials.AL_sound=false(nTrials,1);   %sound contingency trials, after a prior action-left block
trials.AR_sound=false(nTrials,1);   %sound contingency trials, after a prior action-right block

for i = 2:nBlocks
    if strcmp(blocks.type{i},'Sound')    %if this is a sound block
        
        %Create mask for i-th rule block
        blockMask = false(nTrials,1);                   
        firstTrial = blocks.firstTrial(i);
        n = blocks.nTrials(i);
        blockMask(firstTrial:firstTrial+n-1) = true;
        
        if strcmp(blocks.type{i-1},'ActionL') %if it is after an action-left block
            trials.AL_sound(blockMask) = true;
        elseif strcmp(blocks.type{i-1},'ActionR')
            trials.AR_sound(blockMask) = true;
        end
    end
end

%% Check consistency among the extracted trial values
% Call new function checkTrialMasks() here if necessary...