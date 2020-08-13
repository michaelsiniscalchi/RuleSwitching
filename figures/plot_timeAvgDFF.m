function fig = plot_timeAvgDFF( bootAvg, cellIdx, expID, cellType, params )

% Set up figure properties and restrict number of cells, if desired
setup_figprops('timeseries')  %set up default figure plotting parameters
ax = params.panels;
if isempty(params.cellIDs)
    figName = [expID,'_timeAvg']; %Figure name
else
    figName = [expID,'_timeAvg_subset']; %Figure name
end
ax.color(1:numel(cellIdx)) = {params.colors.data2};
ax.lineStyle(1:numel(cellIdx)) = ax.lineStyle;
shadeAlpha = 0.2; %Transparency value for error shading

%% Plot event-aligned dF/F for specified cells
dataRange = [NaN,NaN];
for i = 1:numel(cellIdx)
    % Assign specified signals to each structure in the array 'panels'
    idx = cellIdx(i); %Index in 'cells' structure for cell with corresponding cell ID
    
    %Legend entries
    ax.legend_names{i} =  ['Cell' num2str(idx)]; %Leading trial specifier, all others should generally be fixed
        
    %Signal and confidence bounds
    ax.signal{i} = bootAvg.performed(idx).signal - ...
        mean(bootAvg.performed(idx).signal(bootAvg.t<0)); %Subtract baseline
    %ax.CI{i} = bootAvg.performed(idx).CI;
    ax.CI{i} = NaN(size(bootAvg.performed(idx).CI));
        
    if range(ax.signal{i})>0.4 && strcmp(expID,'180831 M55 RuleSwitching') %Exclude outlier from figure
       ax.signal{i} = NaN(size(ax.signal{i}));
    end
     dataRange = [min([dataRange,ax.signal{i}]),max([dataRange,ax.signal{i}])];%Store min/max of data
end
    %Time axis
    ax.t = bootAvg.t;
    %Titles and Labels
    ax_titles = {ax(:).title}'; %Specified in params.panels
    xLabel = params.xLabel;
    yLabel = params.yLabel;
    %Generate Figure
    fig = plot_trialAvgTimeseries(ax,ax_titles,xLabel,yLabel);
    fig.Name = figName; %Figure name
    fig.Position = [50,400,1800,500]; %LBWH
    fig.Visible = 'off';
    
    %Superimpose the mean of all cells
    allCells = struct2cell(bootAvg.performed);
    allCells = cell2mat(squeeze(allCells(2,:,:)));
    allCells = allCells - mean(allCells(:,bootAvg.t<0),2); %Baseline subtract
    Mean = mean(allCells,1);
    SEM = std(allCells,0,1)./sqrt(size(allCells,1));
    plot(ax.t,Mean,'Color',params.colors.(cellType));
    errorshade(ax.t,Mean-SEM,Mean+SEM,params.colors.(cellType),shadeAlpha);
    ylim([min(dataRange)-0.05*diff(dataRange),max(dataRange)+0.1*diff(dataRange)]);
    
    %Correct the line for t=0   
    ax=gca;
    ylims = ylim; %Store y-axis limits
    lin = findobj('Type','Line','LineStyle',':'); %Find the line
    lin.YData = ylim; %Adjust length
    ylim(ylims); %Make sure original ylims are conserved
    
    %Legend
    if ~params.verboseLegend
        ax.Legend.Visible = 'off';
    end
