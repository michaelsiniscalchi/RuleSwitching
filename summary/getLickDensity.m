function lickDensity = getLickDensity( trialData, trials, edges )

%% Lick density, organized heirarchically by Choice, Cue and Rule
cue = {'upsweep','downsweep'};
rule = {'sound','actionL','actionR'};
binWidth = diff(edges(1:2));
for i = 1:numel(cue)
    for j = 1:numel(rule)
        %Extract specified data
        trialIdx = getMask(trials,{cue{i},rule{j},'last20'});
        unit = sum(trialIdx)*binWidth; %nTrials*seconds/bin
        lickDensity.left.(cue{i}).(rule{j}) = ...
            histcounts([trialData.lickTimesLeft{trialIdx}],edges)/unit; %Counts/trial/second
        lickDensity.right.(cue{i}).(rule{j}) = ...
            histcounts([trialData.lickTimesRight{trialIdx}],edges)/unit;
    end
end
lickDensity.t = edges(1:end-1) + 0.5*binWidth; %Assign to center of time 

%% LICK RATES IN THE 1-SEC PRE- & POST-CUE (***WRITE SEPARATE FUNCTION***)

lickTimesAll = [trialData.lickTimesLeft, trialData.lickTimesRight]; %Concatentate cell arrays for left and right lick times 
binWidth = 1; %For comparison of cueTime +/- binWidth

% Overall Lick Rate Pre- & Post-Cue for all Completed Trials
[lickDensity.preCue.completed, lickDensity.postCue.completed] = ...
    getLickRates(lickTimesAll, ~trials.miss, binWidth);

% Pre-Cue Lick Rates for Comparison of Sound & Action trials
rule = {'sound','action'};
for i = 1:numel(rule)
    lickDensity.preCue.(rule{i}) = ...
        getLickRates(lickTimesAll, getMask(trials,{rule{i},'last20'}), binWidth);
end

% Pre-Cue Lick Rates at Left and Right Ports in Completed Trials
port = {'left','right'};
for i = 1:numel(port)
    lickDensity.preCue.(port{i}) = ...
        getLickRates(lickTimesAll(:,i), ~trials.miss, binWidth);
end

% Post-cue lickrates for comparison of hit & error trials
outcome = {'hit','err'};
for i = 1:numel(outcome)
    [~, lickDensity.postCue.(outcome{i})] = ...
        getLickRates(lickTimesAll, trials.(outcome{i}), binWidth);
end

%%------- INTERNAL FUNCTIONS -----------------------------------------------------------------------
function [ lickRate_pre, lickRate_post ] = getLickRates( lickTimes, trialIdx, binWidth )

unit = 1/(sum(trialIdx)*binWidth); %1/(nTrials*seconds)
lt = [lickTimes{trialIdx,:}]; %Specified lick times
lickRate_pre  = sum(lt >= -binWidth & lt < 0)*unit;
lickRate_post = sum(lt > 0 & lt <= binWidth)*unit;