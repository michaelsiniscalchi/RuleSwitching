
% Difference in Left vs Right Lick Rate across Block Types, Post-Cue (Clear differential response to cues across block types)
% 2-way, Repeated Measures ANOVA:
wsFactors = ["Cue","BlockType"];
[dataStruct, ~] = addComparison(dataStruct,B.all,...
    {"lickDiffs","preCue",["upsweep","downsweep"],["sound","actionL","actionR"]},'ranova',wsFactors); %Report mean & sem
[dataStruct, stats] = addComparison(dataStruct,B.all,...
    {"lickDiffs","postCue",["upsweep","downsweep"],["sound","actionL","actionR"]},'ranova',wsFactors); %Report mean & sem
multComp.lickDiffs = multcompare(stats,'BlockType');
