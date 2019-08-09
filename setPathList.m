%%% smLearning_setPathList 
%
%PURPOSE:   Set up paths to run all analyses of longitudinal imaging & 
%               behavior during learning of sensorimotor associations. 
%AUTHORS: MJ Siniscalchi & AC Kwan, 190701
%
%--------------------------------------------------------------------------
function [ data_dir, code_dir, path_list ] = setPathList

data_dir = 'J:\Data & Analysis\Rule Switching';
code_dir = 'J:\Documents\MATLAB\GitHub\RuleSwitching';

% add the paths needed for this code
path_list = {...
    code_dir;...
    fullfile(code_dir,'common functions');...
    fullfile(code_dir,'common functions','cbrewer');...
    fullfile(code_dir,'exp lists');...
    fullfile(code_dir,'behavior');...
    };
addpath(path_list{:});