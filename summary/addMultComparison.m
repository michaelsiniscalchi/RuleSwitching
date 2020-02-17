function mltCmpStruct = addMultComparison ( mltCmpStruct, stats, vars )

% class(stats)
dispOpts = 'off'; %'Display','off'
if isstruct(stats)
    [c,~,~,gnames] = multcompare(stats,'Display',dispOpts);
    for i = 1:size(c,1)
        S(i).varName = stats.varName;
        S(i).comparison = [gnames{c(i,1)} '-' gnames{c(i,2)}];
        S(i).diff = c(i,4);
        S(i).p = c(i,end);
    end
    
% elseif
    
end

% Concatenate with input structure
mltCmpStruct = [mltCmpStruct S];

%Restrict to populated rows 
idx = ~cellfun(@isempty,{mltCmpStruct.comparison}); %(data_struct(i).varName==[] if any fields are not found in 'stats' structure)
mltCmpStruct = mltCmpStruct(idx);