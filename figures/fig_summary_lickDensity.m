function figs = fig_summary_lickDensity( struct_behavior, params )

B = struct_behavior;
edges = params.trialWindow(1):params.binWidth:params.trialWindow(2);
t = edges(1:end-1)+0.5*params.binWidth;

cellTypes = {'SST','PV','VIP','PYR','All'};
cue = {'upsweep','downsweep'};
rule = {'sound','actionL','actionR'};
titles = {'Sound','Action left','Action right'};

setup_figprops([]);
fig = figure('Name',['Lick density: ' cellTypes{i}]);
tiledlayout(numel(cue),numel(rule));
for row = 1:numel(cue)
    for col = 1:numel(rule)
        %Extract specified data
        for i = 1:numel(B)
        trialIdx = getMask(trials,{cue{row},rule{col},'hit'});
        lickL = histcounts([trialData.lickTimesLeft{trialIdx}],edges)/(sum(trialIdx)*params.binWidth); %Counts/trial/second
        lickR = histcounts([trialData.lickTimesRight{trialIdx}],edges)/(sum(trialIdx)*params.binWidth);
        end
        
        %Plot lick densities
        idx = numel(rule)*(row-1)+col;
        ax(idx) = nexttile; hold on;
        plot(t,lickL,'Color',params.colors{1});        %Lick density, left
        plot(t,lickR,'Color',params.colors{2});        %Lick density, right
        
        %Standardize plotting area
        ylim([1,10]); %0:10Hz
        xlim([edges(1),edges(end)]); %Trial window
        axis square;
        
        %Titles and axis labels
        if row==1
            title(titles{col}); %Title: rule
        end
        if col==1 && row==1
            ylabel({'Upsweep trials'; 'Lick density (Hz)'});
        elseif col==1
             ylabel({'Downsweep trials'; 'Lick density (Hz)'});
        end
    end
end
fig.Position = [400 400 800 500]; %BLWH