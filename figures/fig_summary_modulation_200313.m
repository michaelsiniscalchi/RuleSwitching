function figs = fig_summary_modulation( stats_selectivity, time, params )

setup_figprops('singleUnit');

figs = gobjects(numel(params.figs),1);

%Four subplots: one for each decode type
S = stats_selectivity;
decodeType = fieldnames(S);
nDecode = numel(decodeType);
cellType = fieldnames(S.(decodeType{1}));

for i = 1:numel(params.figs)
    figs(i) = figure('Name',params.figs(i).fig_name,'Position',[10 300 1900 600]);
    var_name = params.figs(i).var_name;
    for j = 1:numel(var_name)
        clearvars pool var Mean SEM Y X

        % Get min and max values for aggregated data to setup axes (needed for swarms)
        for k = 1:numel(decodeType)
            for kk=1:numel(cellType)
                pool{k,kk} = S.(decodeType{k}).(cellType{kk}).(var_name{j}).data;
            end
        end
        pool = cell2mat(pool(:));
        yMin = min(pool);
        yMax = max(pool);
        yRng = range(pool);
        

        %
        for k = 1:numel(decodeType)
            %One plot for each decode type
            ax(k) = subplot(numel(var_name),nDecode,k+nDecode*(j-1)); hold on; %#ok<AGROW>
            %One swarm or line for each cell type
            for kk=1:numel(cellType)
                var = S.(decodeType{k}).(cellType{kk}).(var_name{j});
                Mean(kk,:) = var.mean;
                SEM(kk,:) = var.sem;
                Y{kk} = var.data;
                X{kk} = kk*ones(size(Y{kk}));
                %Color code by cellType
                colors{kk} = [params.colors.(cellType{kk}); params.colors.([cellType{kk} '2'])]; % [darker shade; lighter shade], eg, [colors.SST2; colors.SST]
            end
            
            if size(var.data,2)==1
                %Setup uniform ylims ahead of call to beeswarm
                if yMin<0 
                    ax(k).YLim = [yMin-0.1*yRng, yMax+0.1*yRng];
                else
                    ax(k).YLim = [0, yMax+0.1*yRng];
                end
                ax(k).XLim = [0 numel(cellType)+1];
                ax(k).XTick = 1:numel(cellType); %Bar chart: titles and labels
                ax(k).XTickLabels = cellType;

                %Data by session as beeswarm with overlayed median and IQR
                plot_swarms(ax(k),Y,colors,params.barWidth);
               
            else
                %Line plot with SEM
                for kk=1:numel(cellType)
                    CI = Mean(kk,:) + [SEM(kk,:); -SEM(kk,:)];
                    errorshade(time,CI(1,:),CI(2,:),colors{kk}(1,:),0.2);
                    plot(time,Mean(kk,:),'-','Color',colors{kk}(1,:));
                end
                xlabel('Time from sound cue');
            end
            
            %Get ylims for later standardization
            axis square;
            ylims(k,:) = ylim;
            
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
        ylim(ax,[min(ylims(:)) max(ylims(:))]);
        if size(var.data,2)>1 %If line
            for k = 1:numel(decodeType)
                plot(ax(k),[0 0],[min(ylim) max(ylim)],':k','LineWidth',0.5);
            end
            
        end
        if min(ylim)<0 %draw baseline
            for k = 1:numel(decodeType)
                plot(ax(k),[min(xlim) max(xlim)],[0 0],'-k','LineWidth',0.5);
            end
        end
    end
end

%Specify y-axis label and colors
function ax_label = getYLabel(var_name)
var_label = ...
    {'selIdx','selIdx_t','sigIdx','sigIdx_t','Modulation index';...
    'selMag','selMag_t','sigMag','sigMag_t','Modulation magnitude';...
    'pSig',  'pSig_t',     [],     [],      'Proportion sig. mod.';...
    'pPrefPos',    [],     [],     [],      'Proportion pref. pos. class';...
    'pPrefNeg',    [],     [],     [],      'Proportion pref. neg. class';...
    };
ax_label = var_label(any(strcmp(var_label,var_name),2),end);