%%% plot_swarms()
%
% PURPOSE: To generate custom beeswarm plots for publication. 
%
% INPUT ARGUMENTS:
%       'ax', the axis for plotting, if initialized ahead of time
%       'data', matrix of dimensions (nValues x nGroups) or 1D cell array of length (nGroups) 
%
%---------------------------------------------------------------------------------------------------


function plot_swarms_offset( ax, data, colors, barWidth, dotSize)

%Check for offset
if nargin<5
    dotSize = 1;
    offset = 0;
elseif nargin<6
    offset = 0;
end

%Data can be input as matrix or cell array
if iscell(data)
    %Organize data into a matrix, padded with NaNs if necessary
    M = NaN(max(cellfun(@length,data)),numel(data));
    for i = 1:numel(data)
        M(1:numel(data{i}),i) = data{i};
    end
    data = M;
end

CI(1,:) = prctile(data,25);
CI(2,:) = prctile(data,75);

for i = 1:size(data,2)
    
    %Beeswarm for individual data points
    Y = data(:,i);
    Y = Y(~isnan(Y)); %Remove NaN values if present
    X = (i).*ones(size(Y,1),1) + offset;
    color = colors{i}(2,:); %Lighter shade
    if ~isempty(ax)
        beeswarm(X,Y,'use_current_axes',true,'dot_size',dotSize,'colormap',color,'sort_style','hex',...
        'corral_style','rand'); 
    else
        beeswarm(X,Y,'dot_size',dotSize,'colormap',color,'sort_style','hex',...
        'corral_style','rand'); 
    end
    hold on;
    
    % Horizontal bar for population median
    X = i + [-barWidth/2 barWidth/2] + offset;
    Y = [nanmedian(data(:,i)),nanmedian(data(:,i))];
    color = colors{i}(1,:); %Darker shade
    line(X,Y,'Color',color,'LineWidth',2); hold on; %Horz. bar for Median
    
    % Vertical bar for IQR
    X = [i,i] + offset;
    Y = [CI(1,i),CI(2,i)];
    line(X,Y,'Color',color,'LineWidth',1);  %Vertical Bar for IQR
    
end
