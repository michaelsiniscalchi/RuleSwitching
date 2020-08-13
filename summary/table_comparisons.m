function [ tables, structs ] = table_comparisons( stats )

%% DEFINE AND INITIALIZE COMMON VARIABLES
compStruct = struct('varName',[],'comparison',[],'diff',[],'p',[],'N',[],'testName',[],'stats',[]); %String 'stats' for F(df), t(df), W, etc.
mltCmpStruct = struct('varName',[],'comparison',[],'diff',[],'p',[]);

cellTypes = ["SST", "VIP", "PV", "PYR"]'; %Column vectors
decodeTypes = ["choice_sound", "choice_action", "prior_choice","prior_choice_action",...
    "outcome", "prior_outcome", "rule_SL", "rule_SR"]';
ruleTypes = ["sound", "action"]';
outcomeTypes = ["hit","pErr","oErr","miss"]';

test.behavior = 'ttest';
test.cellTypes = 'kruskalwallis';
% test.cellTypes = 'anova1';
test.modulation = 'signrank';
% test.modulation = 'ttest';

B = stats.behavior;
I = stats.imaging;
S = stats.selectivity;

% NOTES:    multiple entries in first cell of var_spec reserved for 'cellTypes'.
%           multiple entries in last cell of var_spec reserved for 'ruleTypes'.

%% Fixed parameters
alpha = 0.05; %Alpha, threshold parameter for hypothesis testing

%% OVERVIEW

% Number of blocks per session for each cell-type
compStruct = addComparison(...
    compStruct, I, {cellTypes,"nBlocksImg"},'anova1'); %Report mean & sem

%% FORMAL COMPARISONS: LICK DENSITY

% *** Non-Lateralized ***

%Mean Licks/s pre- vs post-cue
compStruct = addComparison(...
    compStruct, B.all, {"lickRates", ["preCue","postCue"],"completed"}, test.behavior); %Report mean & sem

%Mean Licks/s post-cue for hit vs error trials (significant diff of ~
compStruct = addComparison(...
    compStruct, B.all, {"lickRates","postCue",["hit","err"]}, test.behavior); %Report mean & sem;
%*Note: also examined, but did not report pre-cue - very small (~0.1 Hz sig diff)

%Mean Licks/s pre-cue for sound vs action trials (Small overall (-) change in anticipatory licking)
compStruct = addComparison(...
    compStruct, B.all, {"lickRates","preCue",ruleTypes}, test.behavior); %Report mean & sem, diff and t-stats
compStruct = addComparison(...
    compStruct, B.all, {"lickRates", ["preCue","postCue"],"sound"}, test.behavior); %Report diff and t-stats
compStruct = addComparison(...
    compStruct, B.all, {"lickRates", ["preCue","postCue"],"action"}, test.behavior); %Report diff and t-stats

% *** Left vs Right and Difference Across Rules ***

wsFactors = ["Cue","BlockType"]; %Order corresponds to multcompare syntax, eg, multcompare(stats,wsFactors(1),'By',wsFactors(2))

% Difference in Left vs Right Lick Rate across Block Types, Pre-Cue
[compStruct, stats] = addComparison(compStruct,B.all,...
    {"lickDiffs","preCue",["upsweep","downsweep"],["sound","actionL","actionR"]},'ranova',wsFactors); %Report mean & sem
mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName,"BlockType"); %eg, multcompare(stats,wsFactors(1),'By',wsFactors(2))

% Difference in Left vs Right Lick Rate across Block Types, Post-Cue (Clear differential response to cues across block types)
[compStruct, stats] = addComparison(compStruct,B.all,...
    {"lickDiffs","postCue",["upsweep","downsweep"],["sound","actionL","actionR"]},'ranova',wsFactors); %Report mean & sem
%Significant interaction
%Multiple comparisons: upsweep vs downsweep by rule
mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName,wsFactors); %eg, multcompare(stats,wsFactors(1),'By',wsFactors(2))
%Multiple comparisons: sound vs action-left vs action-right by cue
mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName,fliplr(wsFactors));

%Mean Licks/s pre- & post-cue for left vs right ports (Very mild overall Right-bias)
compStruct = addComparison(...
    compStruct, B.all, {"lickRates","preCue",["lickL","lickR"]}, test.behavior); %Report mean & sem
compStruct = addComparison(...
    compStruct, B.all, {"lickRates","postCue",["lickL","lickR"]}, test.behavior); %Report mean & sem

%% FORMAL COMPARISONS: TASK PERFORMANCE

%(***Need Overall trials2crit, pErr, oErr, miss as Descriptive Stat.***)
%(***Need Overall perfLastTrial for hit, pErr, oErr, miss as Descriptive Stat.***)
%(***Also, need to compare overall pErr vs oErr.***)

% Hit, Perseverative, and Other Error Rates across the Two Trials Surrounding a Rule Switch
ruleSubsets = ["all"; ruleTypes];
for i=1:numel(ruleSubsets)
    for j = 1:numel(outcomeTypes)
        compStruct = addComparison(compStruct, B.all,...
            {["perfLastTrial","perfNextTrial"], outcomeTypes(j), ruleSubsets(i)}, test.behavior); %Report mean & sem
    end
end

% One-Sample Test: Next-Trial Performance (vs. 50%)
for i=1:numel(ruleTypes)
    compStruct = addComparison(compStruct, B.all,{"perfNextTrial", "hit", ruleTypes(i)}, {test.behavior,0.5}); %Report mean & sem
end

% Perseverative vs Other Errors in each Rule Type
for i=1:numel(ruleTypes)
    compStruct = addComparison(...
        compStruct, B.all, {["pErr","oErr"], ruleTypes(i)}, test.behavior); %Report mean & sem
end

% Trials-to-Criterion for Sound vs Action
compStruct = addComparison(...
    compStruct, B.all, {"trials2crit", ruleTypes}, test.behavior); %Report mean & sem

% Perseverative Errors for Sound vs Action
compStruct = addComparison(...
    compStruct, B.all, {"pErr", ruleTypes}, test.behavior); %Report mean & sem

%% FORMAL COMPARISONS: MODULATION

% General Task-Related Activity
[compStruct, stats] = addComparison(compStruct,I,{cellTypes,"pTaskCells"},test.cellTypes); %Report med & IQR
mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName);

% *** Modulation by Variable X: Proportion Selective & Mean Magnitude ***

vars = {["pSig",'pNull'],["selMag","nullMag"]};
for i = 1:numel(decodeTypes)
    for j = 1:numel(vars)
        %Primary comparison:  vs. the null distribution
        for k = 1:numel(cellTypes)
            compStruct = addComparison(... %(eg S.choice_sound.SST.pSig)
                compStruct,S,{decodeTypes(i),cellTypes(k),vars{j}},test.modulation); %Report med & IQR
        end
        %Secondary comparison: difference in *corrected* means between cell-types
        %   *Corrected by subtracting null data from each variable
        [compStruct, stats] = addComparison(...
            compStruct,S,{decodeTypes(i),cellTypes,"diffNull",vars{j}(1)},test.cellTypes); %Report mean & sem
        %Post-hoc test if omnibus test (eg ANOVA) yields significant difference
        if str2double(compStruct(end).p)<alpha
            mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName);
        end
    end
end

% *** Preference for Positive vs Negative Class, eg Reward vs No Reward ***
vars = {["pPrefPos","pPrefNeg"],["selIdx","nullIdx"]};
for i = 1:numel(decodeTypes)
    for j = 1:numel(vars)
        for k = 1:numel(cellTypes)
            compStruct = addComparison(... %(eg S.choice_sound.SST.pSig)
                compStruct,S,{decodeTypes(i),cellTypes(k),vars{j}},test.modulation); %Report mean & sem
        end
    end
    %Secondary comparison: difference in *corrected* means between cell-types
    [compStruct, stats] = addComparison(...
        compStruct,S,{decodeTypes(i),cellTypes,"diffNull","selIdx"},test.cellTypes); %Report mean & sem
    %Post-hoc test
    if str2double(compStruct(end).p)<alpha
        mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName);
    end
end

% *** Compare rule modulation between trial subsets for each cell type
decodePairs = {["choice_sound","choice_action"],["rule_SL","rule_SR"]};
vars = ["selMag","pSig","selIdx"];
for i = 1:numel(decodePairs)
    for j = 1:numel(vars)
        for k = 1:numel(cellTypes) % ["rule_SL,"rule_SR"]
            compStruct = addComparison(... %(eg S.choice_sound.SST.diffNull.pSig)
                compStruct,S,{decodePairs{i},cellTypes(k),"diffNull",vars(j)},test.modulation);
        end
    end
end

% *** Post-hoc comparison of outcome modulation in SST to all other cell types ***
vars = ["selMag_t","nullMag_t"];
for i = 1:numel(vars)
    S = posthoc_PreCueAvg(S,"prior_outcome",cellTypes,vars(i)); %Add derivative variable post-hoc
end
S = posthoc_PreCueAvg(S,"prior_outcome",cellTypes,"diffNull","selMag_t"); %Add derivative variable post-hoc

for k = 1:numel(cellTypes)
    compStruct = addComparison(... %(eg S.choice_sound.SST.pSig)
        compStruct,S,{"prior_outcome",cellTypes(k),["preCueAvg_selMag_t","preCueAvg_nullMag_t"]},test.modulation); %Report mean & sem
end
%Secondary comparison: difference in *corrected* means between cell-types
[compStruct, stats] = addComparison(...
    compStruct,S,{"prior_outcome",cellTypes,"diffNull","preCueAvg_selMag_t"},test.cellTypes); %Report mean & sem
if str2double(compStruct(end).p)<alpha
    mltCmpStruct = addMultComparison(mltCmpStruct,stats,compStruct(end).varName);
end

% *NOTE: validated diffNull comparisons by verifying that results of paired signrank are consistent
%   with 1-sample signrank on diffNull (see 'notebook_compareGrps_modulation.m').


%% RETURN DATA STRUCTURES AS TABLES

structs.comparisons = compStruct;
tables.comparisons = struct2table(compStruct);
disp(tables.comparisons);

structs.multiple_comparisons = mltCmpStruct;
tables.multiple_comparisons = struct2table(mltCmpStruct);
disp(tables.multiple_comparisons);


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function [data_struct, stats] = addComparison( data_struct, stats_struct, comp_spec, test_spec, wsFactors )

% INPUT ARGUMENTS
%   'S',        The structure array to be modified, later to be output as table using 'struct2table.m'
%   'stats',    The scalar structure containing fields specified in var_spec.
%   'comp_spec', A cell array specifying hierarchy of fields containing variables for comparison.
%
%---------------------------------------------------------------------------------------------------

%% Argument Check
if nargin<5
    wsFactors = []; %Can be omitted unless repeated measures ANOVA is needed.
end

%% Perform hypothesis tests

% Extract Data for Descriptive Stats or Comparisons
[ data, group ] = getStatsData( stats_struct, comp_spec);

% Perform Statistical Comparisons
if iscell(test_spec) %One-Sample Test
    [ stats, p, stats_str ] = compareOneSample(test_spec{1},data,test_spec{2}); %test_spec{2} is mean/median under H0
else %Between Groups
    [stats, p, stats_str] = compareGroups(test_spec, data, group, wsFactors);
end
% Append Additional Fields from 'dataStruct'

%Variable name
varName = strjoin([comp_spec{cellfun(@length,comp_spec)==1}],'_');

%Comparison
if numel(data)>1
    comparison = comp_spec{cellfun(@length,comp_spec)>1}; %For 1-way comparisons, the unique cell containing multiple fields
else
    comparison = {'1-Sample vs. ',num2str(test_spec{2})};
    test_spec = test_spec{1}; %Extract testName
end

if any(strcmp(comparison,"SST"))
    comparison = "Cell types";
elseif ~isempty(wsFactors)
    comparison = strjoin(wsFactors);
else, comparison = strjoin(comparison);
end

%Estimated effect size
diff = NaN;
if isfield(stats,'diff')
    diff = stats.diff;
end

%Sample size
N = cellfun(@length,data');
if numel(unique(N))==1
    N = unique(N);
end

% Concatenate with Existing Data Structure
idx = length(data_struct)+1;
data_struct(idx,1) = struct(...
    'varName',varName,'comparison',comparison,'diff',num2str(diff),...
    'p',num2str(p),'N',num2str(N),'testName',test_spec,'stats',stats_str); %Enforce column vector

% Remove empty rows
idx = ~cellfun(@isempty,{data_struct.varName}); %(data_struct(i).varName==[] if any fields are not found in 'stats' structure)
data_struct = data_struct(idx);