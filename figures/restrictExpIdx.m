function expIdx = restrictExpIdx( expIDs, specIDs )  

%Restrict to specific sessions, if desired

if isempty(specIDs)
    expIdx = 1:numel(expIDs);
else
    for i = 1:numel(specIDs)
        expIdx(i) = find(ismember(expIDs, specIDs{i}));
    end
end

