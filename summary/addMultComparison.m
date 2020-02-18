function mltCmpStruct = addMultComparison ( mltCmpStruct, stats, vars )

% class(stats)
dispOpts = 'off'; %'Display','off'
if isstruct(stats)
    [c,~,~,gnames] = multcompare(stats,'Display',dispOpts);
    for i = 1:size(c,1)
        S(i).varName = stats.varName; %ADD ARG FOR THIS...can't be used with RM Model
        S(i).comparison = [gnames{c(i,1)} '-' gnames{c(i,2)}];
        S(i).diff = c(i,4);
        S(i).p = c(i,end);
    end
    
elseif strcmp(class(stats),'RepeatedMeasuresModel')
    
    
    if numel(vars)>1
        tbl = multcompare(stats,vars(1),'By',vars(2));
        
        for i = 1:size(tbl,1)
            S(i).varName = [stats.varName '_' tbl{i,1}];
            S(i).comparison = [gnames{c(i,1)} '-' gnames{c(i,2)}];
            S(i).diff = c(i,4);
            S(i).p = c(i,end);
        end
    else
        tbl = multcompare(stats);
    end
    
end


% Concatenate with input structure
mltCmpStruct = [mltCmpStruct S];

%Restrict to populated rows 
idx = ~cellfun(@isempty,{mltCmpStruct.comparison}); %(data_struct(i).varName==[] if any fields are not found in 'stats' structure)
mltCmpStruct = mltCmpStruct(idx);