function transitions = summary_transitions( struct_transitions )

% Initialize summary data structure
cellType = {'SST','VIP','PV','PYR','all'};
temp = struct('sessionID',[],'trials',[],'trialIdx',[],'bins',[],'binIdx',[]);
for i = 1:numel(cellType)
     transitions.(cellType{i}) = struct('all',temp,'sound',temp,'action',temp,...
        'sound_actionR',temp,'actionR_sound',temp,'sound_actionL',temp,'actionL_sound',temp);
end


for i = 1:numel(struct_transitions) %Session index
    
    % Abbreviate and get cell type-specific session index
    S = struct_transitions(i);
    expIdx.all = i;
    expIdx.(S.cellType) = sum(strcmp({struct_transitions(1:i).cellType},S.cellType)); %Cell type spec sessionIdx
    
    cellType = fieldnames(expIdx);
    for j = 1:numel(cellType)
        %Aggregate similarity measures separately for each cell type
        transitions = catTrialSimilarity(transitions, S, expIdx); 
        % Store indices for transitions of each type
transTypes = {'sound_actionR','actionR_sound','sound_actionL','actionL_sound'};
for i = 1:numel(transTypes)    
    idx.(transTypes{i}) = strcmp(type,transTypes{i});
end
idx.all = true(numel(type),1); %all
idx.sound = strcmp(type,'actionL_sound') | strcmp(type,'actionR_sound'); %sound
idx.action = strcmp(type,'sound_actionL') | strcmp(type,'sound_actionR'); %action

% Populate structure according to cell type from current session, 
%   separately for each type of rule transition
cellType = fieldnames(expIdx);
for i = 1:numel(cellType)    

    for j = 1:numel(transTypes) 
        %Session identifier
        typeIdx = idx.(transTypes{j}); %Get specified transition index
        sessionID = ones(sum(typeIdx),1)*expIdx.(cellType{i}); %Label each transition
        
        %Trial-by-trial similarity index
        trials = {input.similarity(typeIdx).trials}';
        trialIdx = {input.similarity(typeIdx).trialIdx}';
        
        %Binned similarity index
        bins = cell2mat({input.similarity(typeIdx).bins}');
        binIdx = cell2mat({input.similarity(typeIdx).binIdx}'); %Might be able to do this just once for each type...
        
        %Concatenate with structure
        T.(cellType{i}).(transTypes{j}) = catStruct(T.(cellType{i}).(transTypes{j}),...
            sessionID,trials,trialIdx,bins,binIdx);
    end
end

    end
    clearvars expIdx;
end

% function T = catTrialSimilarity( T, input, expIdx )

% % Store indices for transitions of each type
% transTypes = {'sound_actionR','actionR_sound','sound_actionL','actionL_sound'};
% for i = 1:numel(transTypes)    
%     idx.(transTypes{i}) = strcmp(type,transTypes{i});
% end
% idx.all = true(numel(type),1); %all
% idx.sound = strcmp(type,'actionL_sound') | strcmp(type,'actionR_sound'); %sound
% idx.action = strcmp(type,'sound_actionL') | strcmp(type,'sound_actionR'); %action
% 
% % Populate structure according to cell type from current session, 
% %   separately for each type of rule transition
% cellType = fieldnames(expIdx);
% for i = 1:numel(cellType)    
% 
%     for j = 1:numel(transTypes) 
%         %Session identifier
%         typeIdx = idx.(transTypes{j}); %Get specified transition index
%         sessionID = ones(sum(typeIdx),1)*expIdx.(cellType{i}); %Label each transition
%         
%         %Trial-by-trial similarity index
%         trials = {input.similarity(typeIdx).trials}';
%         trialIdx = {input.similarity(typeIdx).trialIdx}';
%         
%         %Binned similarity index
%         bins = cell2mat({input.similarity(typeIdx).bins}');
%         binIdx = cell2mat({input.similarity(typeIdx).binIdx}'); %Might be able to do this just once for each type...
%         
%         %Concatenate with structure
%         T.(cellType{i}).(transTypes{j}) = catStruct(T.(cellType{i}).(transTypes{j}),...
%             sessionID,trials,trialIdx,bins,binIdx);
%     end
% end

function S = catStruct(S,varargin)
for ii = 1:numel(varargin)
    field_name = inputname(1+ii); %idx + 1 for struct_in
    if ~iscell(varargin{ii}) && all(isnan(varargin{ii}),'all') %Note: 'cellID' is cell
        varargin{ii} = []; %Remove NaN entries (all(~isSelective)) 
    end
end

