function [ stats, p, stats_str ] = compareOneSample( testName, data, val_H0 )

data = data{:}; %Cell to vector
if strcmp(testName,'ttest')
    [~,p,~,stats] = ttest(data,val_H0);
    stats.diff = mean(data-val_H0);
    stats_str = ['t(' num2str(stats.df) ')=' num2str(abs(stats.tstat))];
elseif strcmp(testName,'signrank')
    [p,~,stats] = signrank(data,val_H0);
    stats.diff = median(data-val_H0);
    stats_str = ['W=' num2str(stats.signedrank)]; %W statistic
end