function fig = fig_summary_task_related_activity( stats_imaging, params )

setup_figprops('singleUnit');

%Four subplots: one for each decode type
S = stats_imaging;
cellType = fieldnames(S);
cellType = cellType(~ismember(cellType,'all'));

fig = figure('Name','Temporal_Modulation','Position',[10 100 1900 600]);
ax = subplot(2,6,1); hold on; %Set to match dimensions of modulation plots
axis square;

%Aggregate data
for i=1:numel(cellType)
    Y(:,i) = {S.(cellType{i}).pTaskCells.data}; %For swarm/box
    X{i} = i*ones(size(Y{i}));
    colors{i} = [params.colors.(cellType{i}); params.colors.([cellType{i} '2'])]; %Color code by cellType: [darker shade; lighter shade], eg, [colors.SST2; colors.SST]
    pH0(i,:) = multOneSampleTest(Y{:,i},params.hypothesisTest,params.alpha/numel(cellType)); %One-sample hypothesis test w/Bonferroni correction
end
pool = cell2mat(Y(1,:)'); % Get min and max values to setup axes (needed for swarms)

% [yMin, yMax] = bounds(pool(:));
[yMin, yMax] = deal(0,1); 
ax = setupAxes(ax,yMin,yMax,params.boxWidth,cellType); %Used to setup other modulation figures.
ylims = [0,1]; %Reset to [0, 1]
xlims = ax.XLim;

fillNullBounds(1:numel(cellType),params.alpha,[0.5 0.5 0.5],[0.5 0.5 0.5]); %fillNullBounds(X,nullData,fillColor,edgeColor); Bonferroni-corrected p-hat
for i = 1:numel(cellType)
    plot_swarms(ax,Y(1,:),colors,params.dotSize,params.lineWidth, params.boxWidth); %Data
    % Indicate significance in XTickLabel 
    %*Expected values not clear for H0
    if pH0(i)
        ax.XTickLabel{i} = [ax.XTickLabel{i},'*'];
    end
end

ax.XLim = xlims; %Preserve x,y lims from setupAxes()
ax.YLim = ylims;
ylabel({'Proportion of neurons'; 'with task-related activity'});


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
axes_handle.YLim = [0, round(yMax+0.3*yRng,1)];

%Set XAxis Properties
if ~isempty(boxWidth) %If box/swarm
    axes_handle.XLim = [1-(boxWidth) numel(xLabels)+(boxWidth)];
    axes_handle.XTick = 1:numel(xLabels); %Box/bar/swarm chart: titles and labels
    axes_handle.XTickLabels = xLabels;
end

ytickformat('%.2g');
axes_handle.Layer = 'top'; %Make sure patches, etc are behind axes

%% Fill Bounds of Null Distribution
function fillNullBounds( X, nullData, fillColor, edgeColor )

nullHi = ones(1,numel(X)).*nullData; %Takes cell type index, kk
nullLo = zeros(1,numel(X)).*nullData; 
nullX = X+[-0.5;0.5];
nullX = [nullX flip(fliplr(nullX))];

% Shading for upper and lower bound of null
% if all(cell2mat(nullData')>0) %Unsigned
%     nullY = [[nullHi; nullHi],zeros(2,numel(nullHi))];
% else
nullY = [[nullHi; nullHi],fliplr([nullLo; nullLo])];
% end
fill(nullX(:),nullY(:),fillColor,'EdgeColor',edgeColor,'LineWidth',1,'FaceAlpha',0.1);

