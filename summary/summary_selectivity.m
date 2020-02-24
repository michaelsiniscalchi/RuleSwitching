function summary = summary_selectivity( summary, decode, cell_type, exp_ID, cellID, params )


%---------------------------------------------------------------------------------------------------

%Initialize output structure
decodeType = fieldnames(decode);
decodeType = decodeType(~strcmp(decodeType,'t'));
for i=1:numel(decodeType)
    if ~isfield(summary.(decodeType{i}),cell_type)
        summary.(decodeType{i}).(cell_type) =...
            struct('selIdx_cells_t',[],'isSelective',logical([]),'pNull_cells',[],... %Aggregated data from individual cells
            'prefPos',[],'prefNeg',[],'expID',[],'cellID',[],...
            'selIdx_t',[],'sigIdx_t',[],'nullIdx_t',[],'selMag_t',[],'nullMag_t',[],... %Collapsed across cells
            'pSig_t',[],'pNull_t',[],...
            'selIdx',[],'sigIdx',[],'nullIdx',[],'selMag',[],'nullMag',[],... %Collapsed across cells & time
            'pSig',[],'pNull',[],...
            'pPrefPos',[],'pPrefNeg',[],'nCells',[]);
    end
end 

% Get all selectivity classes generated in ROC analysis 
for i = 1:numel(decodeType)
    
    %% AGGREGATE AND REDUCE SELECTIVITY RESULTS
    
    disp(['Estimating selectivity statistics (' decodeType{i} ') for session #' num2str(exp_ID) '...']);
    
    % Extract Selectivity Idxs, Idx for Selective Neurons, and Number of Neurons prefering +/- classes 
        [ selIdx_cells_t, isSig_cells_t, isSelective, prefPos, prefNeg ] =...
        get_selectivityTraces(decode,decodeType{i},params);
    
    % Estimate Null Distributions for Selectivity Idx & Chance-Level Proportion of Cells Selective
    [ nullIdx_cells_t, pNull_cells_t, pNull_cells] = ...
        get_nullSelectivity(decode.(decodeType{i}), decode.t, params);
    
    % Estimate Mean Selectivity, Magnitude, and P Significantly Selective as f(t) 
    selIdx_t    = mean(selIdx_cells_t,1); %Mean selectivity idx as a function of time
    selMag_t    = mean(abs(selIdx_cells_t),1); %Mean selectivity magnitude as a function of time
    sigIdx_t    = mean(selIdx_cells_t(isSelective,:),1); %Mean selectivity idx as a function of time 
    pSig_t      = mean(isSig_cells_t,1); %Proportion of neurons significantly selective as function of time   
    
    nullIdx_t    = mean(nullIdx_cells_t,1); %Mean selectivity idx from null distribution as a function of time
    nullMag_t    = mean(abs(nullIdx_cells_t),1); %Mean selectivity magnitude from null distribution as a function of time
    pNull_t      = mean(pNull_cells_t,1); %False discovery rate as function of time       
    
    %Collapsed over time post-trigger
    timeIdx = decode.t>params.t0;
    selIdx  = mean(selIdx_t(timeIdx)); %Grand mean selectivity index
    selMag  = mean(selMag_t(timeIdx)); %Grand mean selectivity magnitude
    sigIdx  = mean(sigIdx_t(timeIdx)); %Same, restricted to significantly selective cells
    pSig    = mean(isSelective); %Overall proportion of cells significantly selective
    
    nullIdx  = mean(nullIdx_t(timeIdx)); %Grand mean selectivity index drawn from a null distribution
    nullMag  = mean(nullMag_t(timeIdx)); %Grand mean selectivity magnitude drawn from a null distribution
    pNull   = mean(pNull_cells); %Overall false discovery rate per cell
        
    %Additional variables
    pPrefPos = mean(prefPos);
    pPrefNeg = mean(prefNeg);
    expID  = exp_ID.*ones(size(selIdx_cells_t,1),1); %Corresponds to expData(expID)
    nCells = size(selIdx_cells_t,1); %Number of cells in FOV

    %% INCORPORATE INTO SUMMARY DATA STRUCTURE
    
    %struct_out = catStruct(struct_in,varargin)
    summary.(decodeType{i}).(cell_type) = catStruct(summary.(decodeType{i}).(cell_type),...
         selIdx_cells_t, isSelective, pNull_cells, prefPos, prefNeg, expID, cellID,... %Vars aggregated across all neurons
         selIdx_t, nullIdx_t, selMag_t, nullMag_t, sigIdx_t, pSig_t, pNull_t,... %Vars averaged across neurons by experiment
         selIdx, nullIdx, selMag, nullMag, sigIdx, pSig, pNull,... %Vars averaged across neurons & time, by experiment
         pPrefPos, pPrefNeg, nCells); 
          
end