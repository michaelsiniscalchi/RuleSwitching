function figs = fig_summary_modulation( stats_selectivity, time, params )

setup_figprops('singleUnit');

figs = gobjects(numel(params.figs),1);

%Four subplots: one for each decode type
S = stats_selectivity;
decodeType = params.decodeTypes;
nDecode = numel(decodeType);
cellType = fieldnames(S.(decodeType{1}));

%Possibly for indicating significance:
% testData = B.selectivity.(decodeType).(cellType).diffNull.(varName).data

for i = 1:numel(params.figs)
    figs(i) = figure('Name',params.figs(i).fig_name,'Position',[10 100 1900 600]);
    var_name = params.figs(i).var_name;
    null_name = params.figs(i).null_name;
%     yMin = NaN(numel(decodeType),1); 
%     yMax = NaN(numel(decodeType),1);
    
    for j = 1:numel(var_name)
        clearvars Mean CI Y X yMin yMax pH0
        %One plot for each decode type
        %One swarm, boxplot, or line for each cell type
        for k = 1:numel(decodeType)
            ax(k) = subplot(numel(var_name),nDecode,k+nDecode*(j-1)); hold on; %#ok<AGROW>
            axis square;
            
            %Aggregate data
            for kk=1:numel(cellType)
                var = S.(decodeType{k}).(cellType{kk}).(var_name{j}); %Mean value from each experiment
                null = S.(decodeType{k}).(cellType{kk}).(null_name{j}); %Null distribution from shuffle
                diffNull = S.(decodeType{k}).(cellType{kk}).diffNull.(var_name{j}); %Difference from null for one-sample H0 test 
                Mean(kk,:) = diffNull.mean; %Grand Mean & SEM; mostly for timeseries...could use for swarm if desired
                CI(kk) = {diffNull.mean + [diffNull.sem; -diffNull.sem]};
                Y(:,kk) = {var.data; null.data}; %For swarm/box
                X{kk} = kk*ones(size(Y{kk}));
                colors{kk} = [params.colors.(cellType{kk}); params.colors.([cellType{kk} '2'])]; %Color code by cellType: [darker shade; lighter shade], eg, [colors.SST2; colors.SST]
                pH0(kk,:) = multOneSampleTest(diffNull.data,params.hypothesisTest,params.alpha); %One-sample hypothesis test 
            end
            pool = cell2mat(Y(1,:)'); % Get min and max values for each decode type to setup axes (needed for swarms)
            [yMin, yMax] = bounds(pool(:));
            
            % Generate Plots
            %BOXPLOTS for Scalars
            if size(var.data,2)==1
                % Set axes limits
                ax(k) = setupAxes(ax(k),yMin,yMax,params.boxWidth,cellType);
                fillNullBounds(1:numel(cellType),Y(2,:),params.nullBound,[0.5 0.5 0.5],[0.5 0.5 0.5]); %fillNullBounds(X,nullData,nullPct,fillColor,edgeColor)
                for kk = 1:numel(cellType)
                    plot_swarms(ax(k),Y(1,:),colors,params.dotSize,params.lineWidth, params.boxWidth); %Data
                    % Indicate significance in XTickLabel
                    if pH0(kk)
                        ax(k).XTickLabel{kk} = [ax(k).XTickLabel{kk},'*'];
                    end
                end
                
            else %LINE plot with SEM
                
                % Setup axes
                [yMin, yMax] = bounds(cell2mat(CI(:)),'all'); %[yMin,yMax] = bounds([min(CI),min(yMin),max(CI),max(yMax)]);
                ax(k) = setupAxes(ax(k),yMin,yMax);
                xlabel('Time from sound cue');
                % Plot results for each cell type
                ylims = ax(k).YLim;
                sigOffset = 0.05*range(ylims);
                sigSpace = 0.03*range(ylims).*(1:numel(cellType))';
                sigY = ylims(2)-sigOffset-sigSpace.*ones(size(time));
                for kk=1:numel(cellType)
                    h(kk) = errorshade(time,CI{kk}(1,:),CI{kk}(2,:),colors{kk}(1,:),0.2);
                    plot(time,Mean(kk,:),'-','Color',colors{kk}(1,:));
                    % Indicate significance above plots
                    sigX = NaN(size(time)); %Initialize
                    sigX(:,pH0(kk,:)) = time(pH0(kk,:));
                    plot(sigX,sigY(kk,:),'.-','Color',colors{kk}(2,:),'MarkerSize',10,'LineWidth',2);
                end
                ax(k).YLim = ylims;
                
            end
            
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
                plot(ax(k),[0 0],[min(ax(k).YLim), max(ax(k).YLim)],':k','LineWidth',0.5);
            end
            
        end
        if min(ylim)<0 %Draw upper/lower bounds of null distribution as 'baseline'
%             for k = 1:numel(decodeType)
%                 plot(ax(k),[min(xlim) max(xlim)],[0 0],'-k','LineWidth',0.5);
%             end
        else
%             set(ax(k),'Layer','top'); %Make sure patches, etc are behind axes
        end
    end
end

%% ---INTERNAL FUNCTIONS----------------------------------------------------------------------------

%% Setup Axes
function axes_handle = setupAxes( axes_handle, yMin, yMax, boxWidth, xLabels )
%Arg check
if nargin<4
    boxWidth = [];
    xLabels = [];
end
%Set YLims 
yRng = yMax - yMin; %Range
if yMin<0
    axes_handle.YLim = [yMin-0.1*yRng, yMax+0.5*yRng];
else
    axes_handle.YLim = [0, yMax+0.5*yRng];
end
%Set XAxis Properties
if ~isempty(boxWidth) %If box/swarm
    axes_handle.XLim = [1-(boxWidth) numel(xLabels)+(boxWidth)];
    axes_handle.XTick = 1:numel(xLabels); %Box/bar/swarm chart: titles and labels
    axes_handle.XTickLabels = xLabels;
else %If line
    
end
axes_handle.Layer = 'top'; %Make sure patches, etc are behind axes

%% Fill Bounds of Null Distribution
function fillNullBounds( X, nullData, nullPct, fillColor, edgeColor )

nullHi = cellfun(@(C) prctile(C,50+nullPct/2),nullData); %Takes cell type index, kk
nullLo = cellfun(@(C) prctile(C,50-nullPct/2),nullData);
nullX = X+[-0.5;0.5];
nullX = [nullX flip(fliplr(nullX))];

% Shading for upper and lower bound of null
% if all(cell2mat(nullData')>0) %Unsigned
%     nullY = [[nullHi; nullHi],zeros(2,numel(nullHi))];
% else
    nullY = [[nullHi; nullHi],fliplr([nullLo; nullLo])];
% end
fill(nullX(:),nullY(:),fillColor,'EdgeColor',edgeColor,'LineWidth',1,'FaceAlpha',0.1);
                    
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