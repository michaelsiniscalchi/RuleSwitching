function output=choice_stats(trials)
% % choice_stats %
%PURPOSE:   Analyze choice behavior in the discrim/flexibility task
%AUTHORS:   AC Kwan 170518
%
%INPUT ARGUMENTS
%   trials:  Structure generated by flex_getTrialMasks().
%
% To plot the output, use plot_choice_stats().

%%

% trials performed (any with a response, excluding misses)
output.nTrialsPerformed=sum(~trials.miss);

% number of trials with correct response
if isfield(trials,'doublereward')  %if there are double or omit reward trials, count those too!
    corrL = (trials.left & (trials.hit | trials.omitreward | trials.doublereward));
    corrR = (trials.right & (trials.hit | trials.omitreward | trials.doublereward));
    output.nCorrect=sum(corrL) + sum(corrR);

    output.nDouble=sum(trials.doublereward);
    output.nOmit=sum(trials.omitreward);    
else    
    corrL = (trials.left & trials.hit);
    corrR = (trials.right & trials.hit);
    output.nCorrect=sum(corrL) + sum(corrR);

    output.nDouble=0;
    output.nOmit=0;
end
output.nErr = sum(trials.err);

% overall correct rate
output.correctRate=(sum(corrL) + sum(corrR))/output.nTrialsPerformed;

% correct rates for left or right port
output.correctRateL=sum(corrL)/sum(trials.upsweep & ~trials.miss);
output.correctRateR=sum(corrR)/sum(trials.downsweep & ~trials.miss);

% correct rate following a certain trial type
trialAfter = [false; trials.hit(1:end-1)];
output.correctRateAfterHit = sum(trialAfter & (corrL | corrR))/sum(trialAfter & ~trials.miss);
if sum(trials.err) > 0
    trialAfter = [false; trials.err(1:end-1)];
    output.correctRateAfterErr = sum(trialAfter & (corrL | corrR))/sum(trialAfter & ~trials.miss);
else
    output.correctRateAfterErr = NaN;
end
trialAfter = [false; trials.miss(1:end-1)];
output.correctRateAfterMiss = sum(trialAfter & (corrL | corrR))/sum(trialAfter & ~trials.miss);
if isfield(trials,'doublereward')
    trialAfter = [false; trials.doublereward(1:end-1)];
    output.correctRateAfterDouble = sum(trialAfter & (corrL | corrR))/sum(trialAfter & ~trials.miss);
    trialAfter = [false; trials.omitreward(1:end-1)];
    output.correctRateAfterOmit = sum(trialAfter & (corrL | corrR))/sum(trialAfter & ~trials.miss);
end

% fraction = miss trial, on trial following a certain trial type
trialAfter = [false; trials.hit(1:end-1)];
output.missFracAfterHit = sum(trialAfter & trials.miss)/sum(trialAfter);
if sum(trials.err) > 0
    trialAfter = [false; trials.err(1:end-1)];
    output.missFracAfterErr = sum(trialAfter & trials.miss)/sum(trialAfter);
else
    output.missFracAfterErr = NaN;
end
trialAfter = [false; trials.miss(1:end-1)];
output.missFracAfterMiss = sum(trialAfter & trials.miss)/sum(trialAfter);
if isfield(trials,'doublereward')
    trialAfter = [false; trials.doublereward(1:end-1)];
    output.missFracAfterDouble = sum(trialAfter & trials.miss)/sum(trialAfter);
    trialAfter = [false; trials.omitreward(1:end-1)];
    output.missFracAfterOmit = sum(trialAfter & trials.miss)/sum(trialAfter);
end

% d-prime
correctRateLeft=output.correctRateL;
correctRateRight=output.correctRateR;
if correctRateLeft==1   %cannot put 0 or 1 as argument for 'norminv' later
    correctRateLeft=0.99;
elseif correctRateLeft==0
    correctRateLeft=0.01;
end
if correctRateRight==1
    correctRateRight=0.99;
elseif correctRateRight==0
    correctRateRight=0.01;
end
output.dprime=norminv(correctRateLeft)-norminv(1-correctRateRight);
    
%% ---- bias in the overall number of left or right response
output.fracLeft = sum(trials.left) / (sum(trials.left) + sum(trials.right));

%% ---- analysis of win-stay, lose-switch behavior

% win-stay, lose-switch
ws = trials.hit_1 & ((trials.left_1 & trials.left) | (trials.right_1 & trials.right)); %if they stay after winning prior trial
ws_denom = trials.hit_1 & (trials.left | trials.right); %only count if they choose on the current trial

ls = trials.err_1 & ((trials.left_1 & trials.right) | (trials.right_1 & trials.left)); %if they switch after losing prior trial
ls_denom = trials.err_1 & (trials.left | trials.right); %only count if they choose on the current trial

output.wsRate = sum(ws)./sum(ws_denom); % fraction win-stay out of all wins
output.lsRate = sum(ls)./sum(ls_denom); % fraction win-stay out of all wins
output.wslsRate = (sum(ws)+sum(ls))./(sum(ws_denom)+sum(ls_denom)); %fraction win-stay-lose-switch out of all trials

% if there was a response, % of stay
stay = (trials.left_1 & trials.left) | (trials.right_1 & trials.right); %if they stay on the choice for consecutive trials
stay_denom = (trials.left_1 | trials.right_1) & (trials.left | trials.right); %only count if they made choices on the current and last trials

output.stayRate = sum(stay)./sum(stay_denom); % fraction stay

%% ---- analysis of correct rate when animal should stay or switch
% this is useful when optimal win-stay % is not 50% because the stimuli
% were not presented in a completely randomly manner (e.g., after 3 hits on
% upsweep trials, we would repeatedly present the downsweep trials until
% animal gets a hit on that cue to encourage solving both cues)

% win-stay when stay is correct choice
nom = trials.hit_1 & (trials.left_1 & trials.upsweep & trials.left) | (trials.right_1 & trials.downsweep & trials.right); %if they stay after winning prior trial
denom = (trials.hit_1 & (trials.left_1 & trials.upsweep) | (trials.right_1 & trials.downsweep)) & (trials.left | trials.right); %only count if they choose on the current trial
output.winstay_corrRate = sum(nom)./sum(denom); % fraction win-stay when stay is correct choice

% win-switch when switch is correct choice
nom = trials.hit_1 & (trials.left_1 & trials.downsweep & trials.right) | (trials.right_1 & trials.upsweep & trials.left); %if they switch after winning prior trial
denom = (trials.hit_1 & (trials.left_1 & trials.downsweep) | (trials.right_1 & trials.upsweep)) & (trials.left | trials.right); %only count if they choose on the current trial
output.winswitch_corrRate = sum(nom)./sum(denom); % fraction win-switch when switch is correct choice

% lose-stay when stay is correct choice
nom = trials.err_1 & (trials.left_1 & trials.upsweep & trials.left) | (trials.right_1 & trials.downsweep & trials.right); %if they stay after losing prior trial
denom = (trials.err_1 & (trials.left_1 & trials.upsweep) | (trials.right_1 & trials.downsweep)) & (trials.left | trials.right); %only count if they choose on the current trial
output.losestay_corrRate = sum(nom)./sum(denom); % fraction lose-stay when stay is correct choice

% lose-switch when switch is correct choice
nom = trials.err_1 & (trials.left_1 & trials.downsweep & trials.right) | (trials.right_1 & trials.upsweep & trials.left); %if they switch after losing prior trial
denom = (trials.err_1 & (trials.left_1 & trials.downsweep) | (trials.right_1 & trials.upsweep)) & (trials.left | trials.right); %only count if they choose on the current trial
output.loseswitch_corrRate = sum(nom)./sum(denom); % fraction lose-switch when switch is correct choice

end


    