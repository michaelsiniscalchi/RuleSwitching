function [ T, dataStruct ] = table_descriptiveStats( stats )

%% DEFINE AND INITIALIZE COMMON VARIABLES
dataStruct = struct('varName',[],'cellType',[],'ruleType',[],...
    'data',[],'mean',[],'sem',[],'median',[],'IQR',[],'sum',[],'N',[],'expID',[]);

cellTypes = ["SST", "VIP", "PV", "PYR"]'; %Column vectors
ruleTypes = ["sound", "action"]';
outcomeTypes = ["hit","pErr","oErr","miss"]';
decodeTypes = ["choice_sound","choice_action","prior_choice","prior_choice_action",...
    "outcome","prior_outcome","rule_SL","rule_SR"]';

B = stats.behavior;
I = stats.imaging;
S = stats.selectivity;

% NOTES:    '{}' in first cell of var_spec reserved for 'cellTypes'.
%           '{}' in last cell of var_spec reserved for 'ruleTypes'.

%% OVERVIEW OF BEHAVIOR & IMAGING

% Number of trials & blocks completed per session
dataStruct = addRow(dataStruct,B.all,{"trialsCompleted"}); %#ok<STRSCALR> %Report mean & sem
dataStruct = addRow(dataStruct,B.all,{"blocksCompleted"}); %#ok<STRSCALR> %Report mean & sem
dataStruct = addRow(dataStruct,B.all,{"sessionsCompleted"}); %#ok<STRSCALR> %Report mean & sem

% Number of identified cells, completed blocks w imaging, etc.
dataStruct = addRow(dataStruct,I,{"all","totalCells"}); %#ok<CLARRSTR> %Report mean & sem
dataStruct = addRow(dataStruct,I,{"all","exclCells"}); %#ok<CLARRSTR> %Report mean & sem
dataStruct = addRow(dataStruct,I,{cellTypes,"inclCells"}); %Report mean & sem
dataStruct = addRow(dataStruct,I,{cellTypes,"nBlocksImg"}); %Report mean & sem


%% LICK RATES & RELATIVE LICK DENSITY

% *** Collapsed across all Rules/Cell Types ***

% Licks/s pre- & post-cue in completed trials
dataStruct = addRow(dataStruct,B.all,{"lickRates",["preCue", "postCue"],"completed"});

% Licks/s post-cue in hit, and error trials
dataStruct = addRow(dataStruct,B.all,{"lickRates","postCue",["hit","err"]});

% Licks/s pre-cue (to compare action & sound)
dataStruct = addRow(dataStruct,B.all,{"lickRates","preCue",["sound","action"]});

% *** For each Block Type ***

% Difference in relative lick density 
dataStruct = addRow(dataStruct,B.all,{"lickDiffs","preCue","all",["sound","actionL","actionR"]});
dataStruct = addRow(dataStruct,B.all,{"lickDiffs","postCue",["upsweep","downsweep"],["sound","actionL","actionR"]});


%% PERFORMANCE MEASURES

% Hit, pErr, oErr, and miss rate in two trials surrounding rule switch
dataStruct = addRow( dataStruct, B.all, {["perfLastTrial","perfNextTrial"],outcomeTypes,"all"});
dataStruct = addRow( dataStruct, B.all, {["perfLastTrial","perfNextTrial"],outcomeTypes,ruleTypes});

% Trials to criterion and frequency of each outcome
dataStruct = addRow(dataStruct,B.all,{"trials2crit","all"}); %#ok<CLARRSTR> %Report mean & sem
dataStruct = addRow(dataStruct,B.all,{"critPerf","all"}); %#ok<CLARRSTR> % %Report mean & sem
dataStruct = addRow(dataStruct,B.all,{outcomeTypes,"all"}); %#ok<CLARRSTR> % %Report mean & sem

% Number trials to criterion, pErr, & oErr, by rule-type
dataStruct = addRow( dataStruct, B.all, {"trials2crit",ruleTypes});
dataStruct = addRow( dataStruct, B.all, {"pErr",ruleTypes});
dataStruct = addRow( dataStruct, B.all, {"oErr",ruleTypes});

%% SUMMARY OF IMAGING EXPERIMENTS
% Proportion of cells with task-related activity
% Presented with example traces from each cell-type
dataStruct = addRow(dataStruct,I,{cellTypes,"pTaskCells"}); %Report mean & sem

%% SUMMARY OF MODULATION RESULTS
vars = ["pSig","selMag","selIdx"];
for i = 1:numel(decodeTypes)
    for j = 1:numel(vars)
        dataStruct = addRow(dataStruct,S,{decodeTypes(i),cellTypes,vars(j)}); %Report mean & sem
    end
end

vars = ["pPrefPos","pPrefNeg"];
for i = 1:numel(decodeTypes)
    for j = 1:numel(cellTypes)
        for k = 1:numel(vars)
            dataStruct = addRow(dataStruct,S,{decodeTypes(i),cellTypes(j),vars(k)}); %Report mean & sem
        end
    end
end

%Mean modulation magnitude during pre-cue period
S = posthoc_PreCueAvg(S,"prior_outcome",cellTypes,"selMag_t"); %Add derivative variable post-hoc
for j = 1:numel(cellTypes)
    dataStruct = addRow(dataStruct,S,{"prior_outcome",cellTypes(j),"preCueAvg_selMag_t"}); %Report mean & sem
end

%% RETURN DATA STRUCTURE AS TABLE

T = dataStruct;
T = rmfield(T,["data","expID","median","IQR"]); %Remove selected fields; can be added back as necessary for reporting
T = struct2table(T);
disp(T);


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function data_struct = addRow( data_struct, stats, var_spec )

% INPUT ARGUMENTS
%   'S',        The structure array to be modified, later to be output as table using 'struct2table.m'
%   'stats',    The scalar structure containing fields specified in var_spec.
%   'var_spec', A cell array specifying hierarchy of fields containing variable of interest.
 
fields = []; 
for i = 1:numel(var_spec)
    nCopies = max(size(fields,1),1);             %Rows in existing array; factor for duplication of new fields
    if length(var_spec{i})==1                               %Individual fieldnames specified as char
        copyField = repmat(var_spec{i},nCopies,1);   %Copy new fieldname for each existing higher-order field
        fields = [fields,copyField];
    else 
%         nCopies = max(size(fields,1),1);             %Rows in existing array; factor for duplication of new fields
        copyField = repmat(var_spec{i},1,nCopies);   %Duplicate new fields for each existing row, eg, ['a','a','a';'b','b','b']
        copyField = reshape(copyField',numel(copyField),1); %Transpose and reshape to column vector, eg, ['a';'a';'a';'b';'b';'b']
        fields = repmat(fields,numel(var_spec{i}),1);       %Copy higher-order fields for each subordinate field specified
        fields = [fields, copyField];                     %Append new set of fieldnames
    end
end

% Extract specified data from 'stats'
len = length(data_struct);
for i = 1:size(fields,1)
    %Evaluate terminal field if present
    s = stats;
    for j = 1:size(fields,2)
        if isfield(s,fields(i,j))
            s = s.(fields(i,j));
        end
    end
    %Append additional fields from 'S'
    if isfield(s,'data')
        
        %Get cell-type from initial field, if present
        s.cellType = string([]);
        s.varName = strcat(fields{i,1:end}); %Initialize variable name
        if ismember(var_spec{1},["SST","VIP","PV","PYR"])
            s.cellType = fields(i,1);
            s.varName = fields(i,end); %Variable name
        end
        %Get rule-type from terminal field, if present
        s.ruleType = [];
        if ismember(var_spec{end},["sound","action"])
            s.ruleType = fields(i,end);
            s.varName = strcat(fields{i,1:end-1});
        end
        data_struct(len+i,1) = s;
    end
end
%Restrict to populated rows 
idx = ~cellfun(@isempty,{data_struct.varName}); %(data_struct(i).varName==[] if any fields are not found in 'stats' structure)
data_struct = data_struct(idx);