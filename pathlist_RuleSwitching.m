%%% smLearning_setPathList
%
%PURPOSE:   Set up paths to run all analyses of longitudinal imaging &
%               behavior during learning of sensorimotor associations.
%AUTHORS: MJ Siniscalchi & AC Kwan, 190701
%
%--------------------------------------------------------------------------
function data_dir = pathlist_RuleSwitching

data_dir = 'J:\Data & Analysis\Rule Switching';
code_dir = 'J:\Documents\MATLAB\GitHub';

% add the paths needed for this code
path_list = {...
    code_dir;...
    fullfile(code_dir,'Image-Stack-Processing');...
    fullfile(code_dir,'Image-Stack-Processing','scim_3');...
    fullfile(code_dir,'RuleSwitching');...
    fullfile(code_dir,'RuleSwitching','behavior');...
    fullfile(code_dir,'RuleSwitching','cell fluo');...
    fullfile(code_dir,'RuleSwitching','fluo analyses');...
    fullfile(code_dir,'RuleSwitching','validation');...
    fullfile(code_dir,'RuleSwitching','figures');...
    fullfile(code_dir,'RuleSwitching','summary');...
    fullfile(code_dir,'RuleSwitching','common functions');...
    fullfile(code_dir,'RuleSwitching','common functions','cbrewer');...
    };
addpath(path_list{:});