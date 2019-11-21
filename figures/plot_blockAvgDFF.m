%%% plotTrialAvgDFF()
%
% PURPOSE:  To plot flexible summary of cellular fluorescence data from two-choice sensory
%               discrimination tasks.
%           
% AUTHORS: MJ Siniscalchi 190912
%
% INPUT ARGS:   
%
%--------------------------------------------------------------------------

function figs = plot_blockAvgDFF( bootAvg, blocks, cellIDs, params )

setup_figprop;  %Default figure plotting parameters

if isfield(params.bootAvg,'cellIDs')
    cellIdx = get_cellIndex(cellIDs,params.bootAvg.cellIDs);
else  %Number cells from 1:nCells
    f = fieldnames(bootAvg);
    cellIdx = 1:numel(bootAvg.(f{1}));
end

%% Plot event-aligned dF/F for each cell

panels = params.bootAvg.panels; %Unpack for readability
for i = 1:numel(cellIdx)
    
    % Assign specified signals to each structure in the array 'panels'
    idx = cellIdx(i); %Index in 'cells' structure for cell with corresponding cell ID
    disp(['Plotting trial-averaged dF/F for cell ' num2str(i) '/' num2str(numel(cellIdx)) '...']);
    for j = 1:numel(panels)
        for k = 1:numel(panels(j).trialSpec)
            trialSpec = panels(j).trialSpec{k}; %Trial specifier, eg {'left','hit','sound'}
            panels(j).signal{k} = bootAvg.(strjoin(trialSpec,'_'))(idx).signal;
            panels(j).CI{k} = bootAvg.(strjoin(trialSpec,'_'))(idx).CI;
        end
        panels(j).t = bootAvg.t;
    end
    
    fig_title = ['Cell ' cells.cellID{idx}]; %cells.cellID{idx} is already a char
    xLabel = params.bootAvg.xLabel;
    yLabel = params.bootAvg.yLabel; 
    
    figs(i) = plot_trialAvgTimeseries(panels,fig_title,xLabel,yLabel);
    figs(i).Name = ['cell' cells.cellID{idx} '_bootavg']; %Figure name
    figs(i).Position = [50,400,1800,500]; %LBWH
    figs(i).Visible = 'off';

end