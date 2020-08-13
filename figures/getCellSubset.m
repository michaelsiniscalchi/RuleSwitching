function cellIdx = getCellSubset(img_beh_file, cellIDs )
%Get Specified Cell IDs and Session Data 
S = load(img_beh_file,'cellID');
if isempty(cellIDs)
    cellIdx = 1:numel(S.cellID);
else
    cellIdx = find(ismember(S.cellID,cellIDs));
end