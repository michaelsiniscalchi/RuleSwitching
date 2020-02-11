function [ T, dataStruct ] = table_comparisons( stats )

%% DEFINE AND INITIALIZE COMMON VARIABLES
dataStruct = struct('varName',[],'cellType',[],'ruleType',[],...
    'diff',[],'P',[],'N',[],'testName',[],'stats',[]);

cellTypes = ["SST", "VIP", "PV", "PYR", "all"]'; %Column vectors
ruleTypes = ["sound", "action", "all"]';
outcomeTypes = ["hit","pErr","oErr","miss"]';

B = stats.behavior;
I = stats.imaging;
S = stats.selectivity;

% NOTES:    '{}' in first cell of var_spec reserved for 'cellTypes'.
%           '{}' in last cell of var_spec reserved for 'ruleTypes'.

%% DESCRIPTIVE STATS: BEHAVIOR

% *** Collapsed across all Rules/Cell Types ***

% Licks/s pre- vs post-cue
dataStruct = addComparison(dataStruct,B.all,{"lickRates",["preCue","postCue"],"completed"},'signrank'); %Report mean & sem

%% RETURN DATA STRUCTURE AS TABLE

T = dataStruct;
T = rmfield(T,["data","expID"]);
T = struct2table(T);
disp(T);


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function data_struct = addComparison( data_struct, stats, comp_spec, test_name )

% INPUT ARGUMENTS
%   'S',        The structure array to be modified, later to be output as table using 'struct2table.m'
%   'stats',    The scalar structure containing fields specified in var_spec.
%   'var_spec', A cell array specifying hierarchy of fields containing varirable of interest.
 
fields = []; 
for i = 1:numel(comp_spec)
    nCopies = max(size(fields,1),1);             %Rows in existing array; factor for duplication of new fields
    if length(comp_spec{i})==1                               %Individual fieldnames specified as char
        copyField = repmat(comp_spec{i},nCopies,1);   %Copy new fieldname for each existing higher-order field
        fields = [fields,copyField];
    else 
%         nCopies = max(size(fields,1),1);             %Rows in existing array; factor for duplication of new fields
        copyField = repmat(comp_spec{i},1,nCopies);   %Duplicate new fields for each existing row, eg, ['a','a','a';'b','b','b']
        copyField = reshape(copyField',numel(copyField),1); %Transpose and reshape to column vector, eg, ['a';'a';'a';'b';'b';'b']
        fields = repmat(fields,numel(comp_spec{i}),1);       %Copy higher-order fields for each subordinate field specified
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
        %Variable name
        s.varName = fields(i,end);
        %Get cell-type from initial field, if present
        s.cellType = [];
        if length(comp_spec{1})>1
            s.cellType = fields(i,1);
        end
        %Get rule-type from terminal field, if present
        s.ruleType = [];
        if length(comp_spec{end})>1
            s.ruleType = fields(i,end);
            s.varName = strcat(fields{i,1:end-1});
        end
        data_struct(len+i,1) = s;
    end
end
%Restrict to populated rows 
idx = ~cellfun(@isempty,{data_struct.varName}); %(data_struct(i).varName==[] if any fields are not found in 'stats' structure)
data_struct = data_struct(idx);