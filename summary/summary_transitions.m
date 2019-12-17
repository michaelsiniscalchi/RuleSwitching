function transitions = summary_transitions( struct_transitions )

%% Initialize summary data structure
cellType = {'SST','VIP','PV','PYR','all'};
temp = struct('sessionID',[],'trials',[],'trialIdx',[],'bins',[],'binIdx',[]);
for i = 1:numel(cellType)
    transitions.(cellType{i}) = struct('all',temp,'sound',temp,'action',temp,...
        'sound_actionR',temp,'actionR_sound',temp,'sound_actionL',temp,'actionL_sound',temp);
end

%% Aggregate data from each session according to cell types and transition types
transTypes = fieldnames(transitions.all);
for i = 1:numel(struct_transitions) %Session index
    
    % Abbreviate and get cell type-specific session index
    T = struct_transitions(i);
    expIdx.all = i;
    expIdx.(T.cellType) = sum(strcmp({struct_transitions(1:i).cellType},T.cellType)); %Cell type spec sessionIdx
    
    % Aggregate similarity measures separately for each cell type
    cellType = fieldnames(expIdx);  %Eg, {'all','SST'}
    for j = 1:numel(cellType)
                
        % Populate structure separately for each type of rule transition
        typeIdx = ismember(transTypes,{'sound_actionR','actionR_sound','sound_actionL','actionL_sound'});
        for k = find(typeIdx)'
            idx.(transTypes{k}) = strcmp(T.type,transTypes{k});
        end
        idx.all = true(numel(T.type),1); %all
        idx.sound = strcmp(T.type,'actionL_sound') | strcmp(T.type,'actionR_sound'); %sound
        idx.action = strcmp(T.type,'sound_actionL') | strcmp(T.type,'sound_actionR'); %action
       
        for k = 1:numel(transTypes)
            %Session identifier
            typeIdx = idx.(transTypes{k}); %Get specified transition index
            sessionID = ones(sum(typeIdx),1)*expIdx.all; %Label each transition
            
            %Trial-by-trial similarity index
            trials = {T.similarity(typeIdx).trials}';
            trialIdx = {T.similarity(typeIdx).trialIdx}';
            
            %Binned similarity index
            bins = cell2mat({T.similarity(typeIdx).bins}');
            binIdx = cell2mat({T.similarity(typeIdx).binIdx}'); %Might be able to do this just once for each type...
                     
            %Concatenate with structure
            transitions.(cellType{j}).(transTypes{k}) = ...
                catStruct(transitions.(cellType{j}).(transTypes{k}),...
                sessionID,trials,trialIdx,bins,binIdx);
            
            %DEBUGGING ()---------------------------------------------------------------------------
            if any(isnan(bins(:)))
                disp([T.sessionID ' [i transType] = ' num2str(i) transTypes{k}]);
            end
            %Cell22 from M58 181025 has NaN for all trialDFF; cell003 missing from timeseries plot
            %Cell16 from M59 181025 has NaN for all trialDFF; cell012 missing from timeseries plot
            
            %---------------------------------------------------------------------------------------
        end
    end
    clearvars expIdx;
end