function figs = fig_summary_modulation( stats_selectivity, time, params )

setup_figprops('singleUnit');

figs = gobjects(numel(params.figs),1);

%Four subplots: one for each decode type
S = stats_selectivity;
decodeType = fieldnames(S);
nDecode = numel(decodeType);
cellType = fieldnames(S.(decodeType{1}));

offset = 0.5*params.boxWidth + 0.05; %width + 0.5*separation param

%Possibly for indicating significance:
% testData = B.selectivity.(decodeType).(cellType).diffNull.(varName).data

for i = 1:numel(params.figs)
    figs(i) = figure('Name',params.figs(i).fig_name,'Position',[10 300 1900 600]);
    var_name = params.figs(i).var_name;
    null_name = params.figs(i).null_name;
    for j = 1:numel(var_name)
        clearvars pool var Mean SEM Y X
        
        % Get min and max values for aggregated data to setup axes (needed for swarms)
        yMin = NaN(numel(decodeType),1); 
        yMax = NaN(numel(decodeType),1); 
        for k = 1:numel(decodeType)
            pool = cell(numel(cellType),1);
            for kk = 1:numel(cellType)
                pool{kk} = S.(decodeType{k}).(cellType{kk}).(var_name{j}).data;
            end
            pool = cell2mat(pool);
            [yMin(k), yMax(k)] = bounds(pool(:));
        end
        
        
        
        %One plot for each decode type
        %One swarm, boxplot, or line for each cell type
        for k = 1:numel(decodeType)
            ax(k) = subplot(numel(var_name),nDecode,k+nDecode*(j-1)); hold on; %#ok<AGROW>
            
            %Aggregate data
            for kk=1:numel(cellType)
                var = S.(decodeType{k}).(cellType{kk}).(var_name{j}); %Mean value from each experiment
                null = S.(decodeType{k}).(cellType{kk}).(null_name{j}); %Null distribution from shuffle
                Mean(kk,:) = var.mean; %Grand Mean & SEM; mostly for timeseries...could use for swarm if desired
                SEM(kk,:) = var.sem;
                Y(:,kk) = {var.data; null.data}; %For swarm/box
                X{kk} = kk*ones(size(Y{kk}));              
                colors{kk} = [params.colors.(cellType{kk}); params.colors.([cellType{kk} '2'])]; %Color code by cellType: [darker shade; lighter shade], eg, [colors.SST2; colors.SST]
            end
            
            % Generate Plots
            if size(var.data,2)==1 && strcmp(var_name{j},'pSig') %PAIRED BOXPLOTS for proportions significant
                for kk = 1:numel(cellType)
                    %Box plot with 9-91% whiskers and median as line
                    % Left box in group
                    plot_basicBox(kk-offset, Y{1,kk},...
                        params.boxWidth, params.lineWidth, colors{kk}(1,:));
                    % Right box in group
                    plot_basicBox(kk+offset, Y{2,kk}, ...
                        params.boxWidth, params.lineWidth, [0.7 0.7 0.7]); %Null: cbrewer gray, a bit lighter
                    % Set axes limits
                    ax(k) = setupAxes(ax(k),yMin(k),yMax(k),params.boxWidth,cellType);  
                end
            elseif size(var.data,2)==1 %BEESWARM
                %Setup uniform ylims ahead of call to beeswarm
                ax(k) = setupAxes(ax(k),yMin(k),yMax(k),params.boxWidth,cellType); 
                %Data by session as beeswarm with overlayed median and IQR
                plot_swarms(ax(k),Y(1,:),colors,params.barWidth,params.dotSize); %Data
            else
                %LINE plot with SEM
                for kk=1:numel(cellType)
                    CI = Mean(kk,:) + [SEM(kk,:); -SEM(kk,:)];
                    errorshade(time,CI(1,:),CI(2,:),colors{kk}(1,:),0.2);
                    plot(time,Mean(kk,:),'-','Color',colors{kk}(1,:));
                end
                xlabel('Time from sound cue');
            end
            
            %Get ylims for later standardization
            axis square;
%             ylims(k,:) = ylim;
            
            %Title for top row
            if isfield(params,'titles') && ~isempty(params.titles)
                ax(k).Title.String = params.titles{k};
            elseif j==1 %Use decode fieldnames
                title_str = [upper(decodeType{k}(1)), decodeType{k}(2:end)];
                title_str(title_str=='_') = ' ';
                ax(k).Title.String = title_str;
            end
            
        end
        
        %Set YLabel
        ax(1).YLabel.String = getYLabel(var_name{j});
        %Set YLims and plot t0 and y = 0
%         ylim(ax,[min(ylims(:)) max(ylims(:))]);
        if size(var.data,2)>1 %If line
            for k = 1:numel(decodeType)
                plot(ax(k),[0 0],[min(ylim) max(ylim)],':k','LineWidth',0.5);
            end
            
        end
        if min(ylim)<0 %Draw upper/lower bounds of null distribution as 'baseline'
%             for k = 1:numel(decodeType)
%                 plot(ax(k),[min(xlim) max(xlim)],[0 0],'-k','LineWidth',0.5);
%             end
        end
    end
end

%% INTERNAL FUNCTIONS

function axes_handle = setupAxes( axes_handle, yMin, yMax, boxWidth, cellType )
yRng = yMax - yMin; %Range
if yMin<0
    axes_handle.YLim = [yMin-0.1*yRng, yMax+0.3*yRng];
else
    axes_handle.YLim = [0, yMax+0.3*yRng];
end
axes_handle.XLim = [1-(3*boxWidth) numel(cellType)+(3*boxWidth)];
axes_handle.XTick = 1:numel(cellType); %Box/bar/swarm chart: titles and labels
axes_handle.XTickLabels = cellType;

%% Specify Y-AXIS LABEL AND COLORS
function ax_label = getYLabel(var_name)
var_label = ...
    {'selIdx','selIdx_t','sigIdx','sigIdx_t','Modulation index';...
    'selMag','selMag_t',    [],     [],      'Modulation magnitude';...
    'pSig',  'pSig_t',      [],     [],      'Proportion sig. mod.';...
    'pPrefPos',    [],      [],     [],      'Proportion pref. pos. class';...
    'pPrefNeg',    [],      [],     [],      'Proportion pref. neg. class';...
    };
ax_label = var_label(any(strcmp(var_label,var_name),2),end);