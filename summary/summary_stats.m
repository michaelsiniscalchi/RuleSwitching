function stats = summary_stats( stats, input, type )

%BE CAREFUL ABOUT TREATMENT OF NANS!

switch type
   
    case 'behavior'
        cellTypes = fieldnames(input);
        for i = 1:numel(cellTypes)

            %Total number of trials & trials performed 
            expID = input.(cellTypes{i}).sessionID;
            S.(cellTypes{i}).nTrials = calcStats(input.(cellTypes{i}).nTrials,expID);
            S.(cellTypes{i}).trialsPerf = calcStats(input.(cellTypes{i}).trialsPerf,expID);
            
            %Block performance
            vbl = {'trials2crit','pErr','oErr'};
            rule = {'sound','action'};
            for j = 1:numel(vbl)
                for k = 1:numel(rule)
                    S.(cellTypes{i}).(vbl{j}).(rule{k}) = ...
                        calcStats(input.(cellTypes{i}).(vbl{j}).(rule{k}),expID);
                end
            end
  
            %Lick Density
            choice = {'left','right'};
            cue = {'upsweep','downsweep'}; 
            rule = {'sound','actionL','actionR'};
            for ii = 1:numel(choice)
                for jj = 1:numel(cue)
                    for kk = 1:numel(rule)
                        data = input.(cellTypes{i}).lickDensity.(choice{ii}).(cue{jj}).(rule{kk});
                        S.(cellTypes{i}).lickDensity.(choice{ii}).(cue{jj}).(rule{kk}) = ...
                            calcStats(data,expID);
                    end
                end
            end
            
            %Performance curve surrounding rule switch
            rule = {'sound','action'};
            vbl = {'hit','pErr','oErr','miss'}; %Proportion hit, pErr, oErr, & miss, by session
            for j = 1:numel(rule)
                for k = 1:numel(vbl)
                    S.(cellTypes{i}).perfCurve.(rule{j}).(vbl{k}) = ...
                        calcStats(input.(cellTypes{i}).perfCurve.(rule{j}).(vbl{k}),expID);
                end
            end
  
        end
  
    case 'selectivity'
        %Get Mean, SEM, N, and Exp. ID for each terminal node in struct selectivity
        decodeTypes = fieldnames(input);
        decodeTypes = decodeTypes(~strcmp(decodeTypes,'t'));
        time = input.t;
        for i = 1:numel(decodeTypes)
            cellTypes = fieldnames(input.(decodeTypes{i}));
            for j = 1:numel(cellTypes)
                varNames = fieldnames(input.(decodeTypes{i}).(cellTypes{j})); %varNames = {'selMag','sigMag','pSig','nPref_pos','nPref_neg','nCells'};
                varNames = varNames(~ismember(varNames,{'cellID','expID'}));
                for k = 1:numel(varNames)
                    %***FUTURE EDIT: use "stats = calcStats(data, expID)" as above.
                    %All data points 
                    s.data = input.(decodeTypes{i}).(cellTypes{j}).(varNames{k});
                    %Mean across first dimension (cells or experiments)
                    s.mean = mean(s.data,1);
                    %SEM across first dimension (cells or experiments)
                    s.sem = std(s.data,0,1)./ sqrt(size(s.data,1));
                    %Unit of measure, N
                    s.N = size(s.data,1);
                    %Experiment ID
                    s.expID = input.(decodeTypes{i}).(cellTypes{j}).expID; %N = nCells
%                     if s.N < numel(s.expID) %N = nExperiments %**???*** Probably should not be here...
%                         s.expID = unique(s.expID);
%                     end
                    %Incorporate data into output structure
                    S.(decodeTypes{i}).(cellTypes{j}).(varNames{k}) = s;
                end
            end
        end
end
stats.(type) = S;