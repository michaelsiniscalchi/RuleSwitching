function cellIdx = restrictCellIDs( expIDs, cellIDs )  

cellIdx = cell(numel(expIDs),1); %Initialize with default: [] interpreted as all cells
if numel(expIDs)~=numel(cellIdx)
    error("Error: params.cellIDs must correspond one-to-one with params.expIDs.");
elseif ~isempty(cellIDs)
        cellIdx = cellIDs;
end