%%% plot_swarms()
%
% PURPOSE: To generate custom beeswarm plots for publication. 
%
% INPUT ARGUMENTS:
%       'ax', the axis for plotting, if initialized ahead of time
%       'data', matrix of dimensions (nValues x nGroups) or 1D cell array of length (nGroups) 
%
%---------------------------------------------------------------------------------------------------


function plot_swarms( ax, data, colors, dotSize, lineWidth, boxWidth, offset)

%% Arg Check
if nargin<4
    dotSize = 1;
    boxWidth = 0;
    offset = 0;
elseif nargin<6
    boxWidth = 0;
    offset = 0;
elseif nargin<7
    offset = 0;
end

%% Data can be input as matrix or cell array: convert if necessary
if iscell(data)
    %Organize data into a matrix, padded with NaNs if necessary
    M = NaN(max(cellfun(@length,data)),numel(data));
    for i = 1:numel(data)
        M(1:numel(data{i}),i) = data{i};
    end
    data = M;
end

for i = 1:size(data,2)
    
    %Beeswarm for individual data points
    Y = data(:,i);
    Y = Y(~isnan(Y)); %Remove NaN values if present
    X = (i).*ones(size(Y,1),1) + offset;
    color = colors{i}(2,:); %Lighter shade
    if ~isempty(ax)
        %Store axes properties; beeswarm() does not preserve them... 
        propNames = {'PlotBoxAspectRatio','XTick','XTickLabel'};
        propVals = get(ax,propNames);
        %Generate beeswarm plot
        beeswarm(X,Y,'use_current_axes',true,'dot_size',dotSize,'colormap',color,'sort_style','hex',...
            'corral_style','gutter');
        %Restore XLabel, PlotBoxAspectRatio, etc.
        set(ax,propNames,propVals); 
    else
        beeswarm(X,Y,'dot_size',dotSize,'colormap',color,'sort_style','hex',...
        'corral_style','rand'); 
    end
    hold on;

    if boxWidth>0
        color = colors{i}(1,:); %Darker shade
        plot_basicBox(X(1),Y,boxWidth,lineWidth,color,0); %Scalar X needed for boxplot
    end
    
%     % BARS for Mean +/- SEM
%     % Horizontal bar for population median
%     X = i + [-barWidth/2 barWidth/2] + offset;
%     Y = [nanmedian(data(:,i)),nanmedian(data(:,i))];
%     color = colors{i}(1,:); %Darker shade
%     line(X,Y,'Color',color,'LineWidth',lineWidth); hold on; %Horz. bar for Median
%     
%     % Vertical bar for IQR
%     X = [i,i] + offset;
%     Y = [CI(1,i),CI(2,i)];
%     line(X,Y,'Color',color,'LineWidth',0.5*lineWidth);  %Narrow vertical Bar for IQR
    
end
