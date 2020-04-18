function fig = fig_summary_selectivity( decode, decode_type, time, params, sig_flag )

%Initialize figure
if nargin<5 || ~strcmp(sig_flag,'sig')
    sig_flag = false;
    fig = figure('Name',['summary_modulation_' decode_type]);
else
    fig = figure('Name',['summary_modulation_' decode_type '_sigCells']);
end
fig.Position = [100,100,1600,800]; %LBWH
% fig.Visible = 'off';
fig.Visible = 'on';

%% ---Plot 1: One modulation heatmap for each cell type --------------------------------------------

% Set up figure properties
setup_figprops('heatmap');  %set up default figure plotting parameters

cellType = fieldnames(decode.(decode_type));
for i = 1:numel(cellType)
    
    d = decode.(decode_type).(cellType{i});  %Unpack cell-type spec data from struct
    
    %Sort by preference then center-of-mass
    [sel_sorted,sig_sorted,cellIdx,~] = sort_selectivityTraces(d.selIdx_cells_t, d.isSelective, time);
    
    %Option: present only significantly modulated neurons
    if sig_flag
        sel_sorted = sel_sorted(sig_sorted,:);
        cellID = d.cellID(cellIdx(sig_sorted));
        expID = d.expID(cellIdx(sig_sorted));
    else
        cellID = d.cellID(cellIdx);
        expID = d.expID(cellIdx);
    end
    
    %Display results
    tile = i+[0,4,8,12];
    ax(i) = subplot(5,4,tile);  %#ok<*AGROW>
    img = imagesc(sel_sorted);  hold on;
    img.XData = [time(1) time(end)];
    colormap(params.(decode_type).cmap);
    clims(i) = max(abs(img.CData(:)));
    
    %Plot t0
    axis tight;
    Y = 1:img.YData(2);
    dt_line(i) = plot(zeros(size(Y)),Y,'k:','LineWidth',1);
    
    %Generate data tips on t0 line for access to cell IDs
    dt_line(i).DataTipTemplate.DataTipRows(1) =...
        dataTipTextRow('Cell ID',cellID);
    dt_line(i).DataTipTemplate.DataTipRows(2) =...
        dataTipTextRow('Exp. ID',expID);
    
    %Titles and axis labels
    title(cellType{i});
    ax(i).XTickLabel = []; %Leave ticklabels off; put them on bottom plots
end

% Standardize color scale across cell types
for i = 1:numel(ax)
    caxis(ax(i),[-max(clims) max(clims)]); %Y = prctile(X,p,dim)
    axis(ax(i),'square');
    pos(i,:) = ax(i).Position; %Get position to maintain after colorbar()
    if i==numel(cellType)
        colorbar;
    end
end
for i = 1:numel(ax)
    ax(i).Position = pos(i,:);
end
ax(1).YLabel.String = params.yLabel; % YLabel for leftmost plot


%% --- Plot 2: Proportion of significantly modulated neurons & mean modulation idx --------

for i = 1:numel(cellType)
    
    d = decode.(decode_type).(cellType{i}); %Unpack cell-type spec data from struct
    
    %Mean modulation magnitude +- SEM
    val = d.selMag_t;
    mag.mean = nanmean(val);
    SEM = nanstd(val,0)/sqrt(size(val,1));
    mag.CI = [mag.mean + SEM; mag.mean - SEM];
    
    %Proportion of neurons significantly modulated
    pSig.mean = nanmean(d.pSig_t); %Across experiments
    SEM = nanstd(d.pSig_t,0)/sqrt(size(d.pSig_t,1));
    pSig.CI = [pSig.mean + SEM; pSig.mean - SEM];
    
    %Display results
    tile = i+16; %Last row
    ax2(i) = subplot(5,4,tile); hold on %#ok<*AGROW>
    pos = ax2(i).Position;
        
    yyaxis left;
    errorshade(time,pSig.CI(1,:),pSig.CI(2,:),'k',0.2);
    line(time,pSig.mean,'Color','k');
    axis tight;
    ylims_L(i,:) = ylim; %Get ylims 
    
    yyaxis right;
    c = params.(decode_type).color;
    errorshade(time,mag.CI(1,:),mag.CI(2,:),c,0.2);
    line(time,mag.mean,'Color',c);
    axis tight;
    ylims_R(i,:) = ylim;
        
    ax2(i).Position = pos;
    ax2(i).XLabel.String = params.xLabel;
    
end

% Standardize range and label axes
for i = 1:numel(ax2)
    ax2(i).YAxis(1).Color = 'k';
    ax2(i).YAxis(2).Color = c;
    ax2(i).YAxis(1).Limits = [min(ylims_L(:)) max(ylims_L(:))];
    ax2(i).YAxis(2).Limits = [min(ylims_R(:)) max(ylims_R(:))];
end
ax2(1).YAxis(1).Label.String = 'P sig.';
ax2(end).YAxis(2).Label.String = 'Mean mag.';

