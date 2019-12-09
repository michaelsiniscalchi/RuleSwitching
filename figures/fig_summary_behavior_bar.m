function fig = fig_summary_behavior( behavior, cellType, params )

D = behavior.(cellType); %Extract cell-type specific data

%% SETUP PANELS FOR PLOTTING
bar_width = 0.8;
titles = {'Trials Perf.','Trials to Crit.','Persev. Errors','Other Errors'};
% titles = {'Trials Perf.','Trials to Crit.','Persev. Errors','Other Errors'};

setup_figprops([]);
fig = figure('Name',['Summary behavioral statistics - ' cellType]);
fig.Position = [400 400 800 500]; %BLWH
tiledlayout(1,4);
ax = gobjects(2,1);

%% PLOT TOTAL TRIALS, TRIALS TO CRITERION, & PERSEVERATIVE OR OTHER ERRORS

% % Total Trials Performed
% ax(1) = nexttile;
% dataBar(D.nTrials.data,[1,1,1],[]);
% b(1) = bar(D.nTrials.median,'FaceColor','none'); hold on;
% title(titles{1});
% ylabel('Number of trials');

% Trials to Criterion, Perseverative Errors, & Other Errors

%Organize data into pairs for sound vs. action
vars = {'trials2crit','pErr','oErr'};
for i=1:numel(vars)
    s.(vars{i}).median = [D.(vars{i}).sound.median, D.(vars{i}).action.median];
    s.(vars{i}).data = [D.(vars{i}).sound.data, D.(vars{i}).action.data];
end

for i = 1:numel(vars)
%Plot population median
ax(i) = nexttile;
barColor = cell2mat(params.ruleColors(:));
b(i) = dataBar(s.(vars{i}).data,barColor,'grouped');

title(titles{1+i}); %Title
ylims(i,:) = ylim; %#ok<AGROW> %Store ylims for later standardization
end

%% Formatting

% YLable for first of three block averaged variables
ylabel(ax(1),'Number of trials per block');

% Set YLims for Error Plots
ylims = ylims(2:3,:);
ylim(ax(2:3),[min(ylims(:)) max(ylims(:))]);
ax(3).YAxis.Visible = 'off';

% Equalize width of each bar
% ax(1).XLim = ax(2).XLim-0.5; %For 'Trials Performed'
for i = 1:numel(b)
b(i).BarWidth = bar_width; 
end
set(ax,'Box','off','XTick',[]); %Box off for all

function b = dataBar(data,barColor,type)

%***Later, modify to do mean+SEM or median+IQR
markerColor = [0.5,0.5,0.5];

Median = median(data);
Q1 = prctile(data,25);
Q3 = prctile(data,75);

% Bar for population median
if strcmp(type,'grouped')
    b = bar(Median,'grouped','FaceColor','flat','EdgeColor','flat'); hold on; %Bar for median
%     %Line for IQR or SEM
%     for j = 1:2
%         X = repmat(b.XEndPoints(j),1,2);
%         Y = [Q(1,j),Q(3,j)];
%         line(X,Y,'Color',barColor(j,:));
%     end

else
     b = bar(Median,'FaceColor','flat','EdgeColor','flat'); hold on; %Bar for median
    
end
b.CData = barColor;

% Plot data from individual sessions 
bar_center = b.XEndPoints;

X = repmat(bar_center,size(data,1),1);
Y = data;
line(X,Y,'Marker','o','Color',markerColor,'LineStyle','none','LineWidth',1);  

% %Beeswarm - must optimize if used...
% ylim([0, max(data(:))+ 0.1*max(data(:))]);
% for i=1:size(data,2)
%     X = bar_center(i).*ones(size(data,1),1);
%     Y = data(:,i);
%     beeswarm(X,Y,'dot_size',1,'use_current_axes',true,'colormap',markerColor,'sort_style','rand');
% end  
