function T = table_descriptiveStats( stats )

%statsTable = struct('behavior',table(),'imaging',[],'cellFluo',[]);

%T.VariableNames = {'VarName','Mean','SEM','Median','IQR','N'}
% {Varname cellType ruleType }
% eg, stats.behavior.SST.trials2crit.sound

%recursive fieldnames from MATLAB Central: names = fieldnamesr(stats,'struct');

%% DEFINE AND INITIALIZE COMMON VARIABLES
S = struct('VarName',[],'cellType',[],'ruleType',[],...
    'mean',[],'sem',[],'median',[],'IQR',[],'sum',[],'N',[]);

cellTypes = {'SST';'VIP';'PV';'PYR';'all'};
ruleTypes = {'sound';'action';'all'};

%% Descriptive Stats: Behavior
B = stats.behavior;


% Collapsed across all Rules/Cell Types

% Number of trials completed per session
%stats.behavior.SST.trialsCompleted
% S = addRow( S, 'trialsCompleted', cellType, ruleType, stats ); %eg, addRow( S, 'trials2crit', 'each', 'each', stats )
% S = addRow( S, stats.behavior.SST.trialsCompleted);
% A couple test cases:
S = addRow( S, stats.behavior, {cellTypes,'trialsCompleted'});
S = addRow( S, stats.behavior, {cellTypes,'trials2crit',ruleTypes});

% Number of blocks completed per session

% Licks/s in 2 s pre- vs post-cue

% For each Cell Type
% diff. licks/s in 2 s pre- vs post-cue

% For each Block Type:
%
% -licks/s pre- & post-cue
% -Hit & perseverative error rates in two trials surrounding rule switch (estimate from 'perfcurve')


%% ------- INTERNAL FUNCTIONS ----------------------------------------------------------------------

function S = addRow( S, stats, var_spec )

% INPUT ARGUMENTS
%   'S',        The structure array to be modified, later to be output as table using 'struct2table.m'
%   'stats',    The scalar structure containing fields specified in var_spec.
%   'var_spec', A cell array specifying hierarchy of fields containing varirable of interest.
 
if isempty(var_spec)
        s = stats;
        return
end

%Get number of output structs
cellfun(@length,var_spec(iscell(var_spec)))

for i = 1:numel(var_spec)
    if isstring(var_spec{i})          %Individual fieldnames specified as char
        s = stats.(var_spec{i});
    elseif iscell(var_spec{i})        %Multiple fieldnames specified in cell array or chars
        for j = 1:numel(var_spec{i})
            if ischar(var_spec{i}{j})
                s(i,j) = stats.(var_spec{i}{j});
            elseif iscell(var_spec{i}{j}) 
                for k = 1:numel(var_spec{i})
                
                end
            end
        end
        
    end
end
