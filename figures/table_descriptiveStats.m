function [ T, data_struct ] = table_descriptiveStats( stats )

%statsTable = struct('behavior',table(),'imaging',[],'cellFluo',[]);

%T.VariableNames = {'VarName','Mean','SEM','Median','IQR','N'}
% {Varname cellType ruleType }
% eg, stats.behavior.SST.trials2crit.sound

%recursive fieldnames from MATLAB Central: names = fieldnamesr(stats,'struct');

%% DEFINE AND INITIALIZE COMMON VARIABLES
S = struct('varName',[],'cellType',[],'ruleType',[],...
    'data',[],'mean',[],'sem',[],'median',[],'IQR',[],'sum',[],'N',[],'expID',[]);

cellTypes = ["SST";"VIP";"PV";"PYR";"all"];
ruleTypes = ["sound";"action";"all"];

%% Descriptive Stats: Behavior
B = stats.behavior;


% Collapsed across all Rules/Cell Types

% Number of trials completed per session
%stats.behavior.SST.trialsCompleted
% S = addRow( S, 'trialsCompleted', cellType, ruleType, stats ); %eg, addRow( S, 'trials2crit', 'each', 'each', stats )
% S = addRow( S, stats.behavior.SST.trialsCompleted);
% A couple test cases:
S = addRow( S, stats.behavior, {cellTypes,"trialsCompleted"});
S = addRow( S, stats.behavior, {cellTypes,"trials2crit",ruleTypes});
disp()
% Number of blocks completed per session

% Licks/s in 2 s pre- vs post-cue

% For each Cell Type
% diff. licks/s in 2 s pre- vs post-cue

% For each Block Type:
%
% -licks/s pre- & post-cue
% -Hit & perseverative error rates in two trials surrounding rule switch (estimate from 'perfcurve')


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function data_struct = addRow( data_struct, stats, var_spec )

% INPUT ARGUMENTS
%   'S',        The structure array to be modified, later to be output as table using 'struct2table.m'
%   'stats',    The scalar structure containing fields specified in var_spec.
%   'var_spec', A cell array specifying hierarchy of fields containing varirable of interest.
 
fields = []; 
for i = 1:numel(var_spec)
    if length(var_spec{i})==1                               %Individual fieldnames specified as char
        copyField = repmat(var_spec{i},size(fields,1),1);   %Copy new fieldname for each existing higher-order field
        fields = [fields,copyField];
    else 
        nCopies = max(size(fields,1),1);             %Rows in existing array; factor for duplication of new fields
        copyField = repmat(var_spec{i},1,nCopies);   %Duplicate new fields for each existing row, eg, ['a','a','a';'b','b','b']
        copyField = reshape(copyField',numel(copyField),1); %Transpose and reshape to column vector, eg, ['a';'a';'a';'b';'b';'b']
        fields = repmat(fields,numel(var_spec{i}),1);       %Copy higher-order fields for each subordinate field specified
        fields = [fields, copyField];                     %Append new set of fieldnames
    end
end

% Get variable name, cell-type, and rule-type
%varName = repmat(var_spec(end),size(fields,1),1);
%cellType = mat2cell(fields(:,1),ones(size(fields,1),1));


% %Initialize data structure
% data_struct = struct('varName',varName,'cellType',cellType);

% Extract specified data
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
        s.varName = fields(i,end);
        s.cellType = fields(i,1);
        s.ruleType = "all";
        %Get ruletype from terminal field, if present
        if length(var_spec(end))>1 
            s.ruleType = fields(i,end);
            s.varName = fields(i,end-1);
        end
        data_struct = [data_struct s];
%         data_struct = [data_struct s];
    end
end

