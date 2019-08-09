function [ dirs, expData ] = expData_RuleSwitching(data_dir)

%PURPOSE: Create data structure for imaging tiff files and behavioral log files
%AUTHORS: AC Kwan, 170519.
%
%INPUT ARGUMENTS
%   data_dir:    The base directory to which the raw data are stored.  
%
%OUTPUT VARIABLES
%   dirs:        The subfolder structure within data_dir to work with
%   expData:     Info regarding each experiment

dirs.data = fullfile(data_dir,'data');
dirs.analysis = fullfile(data_dir,'analysis');
dirs.summary = fullfile(data_dir,'summary');

%% SST+ Interneurons (n=15)
i=1;
expData(i).sub_dir = '170928 M47 RuleSwitching'; 
expData(i).logfile = 'M47_RULESWITCHING_1709281709.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=2;
expData(i).sub_dir = '171012 M47 RuleSwitching'; 
expData(i).logfile = 'M47_RULESWITCHING_1710121657.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=3;
expData(i).sub_dir = '171114 M47 RuleSwitching'; 
expData(i).logfile = 'M47_RULESWITCHING_1711141445.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=4;
expData(i).sub_dir = '171024 M47 RuleSwitching'; 
expData(i).logfile = 'M47_RULESWITCHING_1710241601.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=5;
expData(i).sub_dir = '171103 M47 RuleSwitching'; 
expData(i).logfile = 'M47_RULESWITCHING_1711031516.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=6;
expData(i).sub_dir = '170929 M48 RuleSwitching'; 
expData(i).logfile = 'M48_RULESWITCHING_1709291124.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=7;
expData(i).sub_dir = '171013 M48 RuleSwitching'; 
expData(i).logfile = 'M48_RULESWITCHING_1710131613.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=8;
expData(i).sub_dir = '171112 M49 RuleSwitching'; 
expData(i).logfile = 'M49_RULESWITCHING_1711121311.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=9;
expData(i).sub_dir = '171101 M49 RuleSwitching'; 
expData(i).logfile = 'M49_RULESWITCHING_1711011702.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=10;
expData(i).sub_dir = '171011 M50 RuleSwitching'; 
expData(i).logfile = 'M50_RULESWITCHING_1710111555.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=11;
expData(i).sub_dir = '171014 M50 RuleSwitching'; 
expData(i).logfile = 'M50_RULESWITCHING_1710141243.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=12;
expData(i).sub_dir = '171027 M50 RuleSwitching'; 
expData(i).logfile = 'M50_RULESWITCHING_1710271654.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=13;
expData(i).sub_dir = '171005 M50 RuleSwitching'; 
expData(i).logfile = 'M50_RULESWITCHING_1710051344.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=14;
expData(i).sub_dir = '171103 M51 RuleSwitching'; 
expData(i).logfile = 'M51_RULESWITCHING_1711031705.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;
i=15;
expData(i).sub_dir = '171109 M51 RuleSwitching'; 
expData(i).logfile = 'M51_RULESWITCHING_1711091542.log';
expData(i).cellType = 'SST'; %Cell-type label 
expData(i).npCorrFactor = 0.5;

%% VIP+ Interneurons (N=20)
i=16;
expData(i).sub_dir = '180927 M57 RuleSwitching'; 
expData(i).logfile = 'M57_RULESWITCHING_1809271436.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=17;
expData(i).sub_dir = '181010 M57 RuleSwitching'; 
expData(i).logfile = 'M57_RULESWITCHING_1810101343.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=18;
expData(i).sub_dir = '181012 M57 RuleSwitching'; 
expData(i).logfile = 'M57_RULESWITCHING_1810121437.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=19;
expData(i).sub_dir = '181026 M57 Ruleswitching'; 
expData(i).logfile = 'M57_RULESWITCHING_1810261247.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;

i=20;
expData(i).sub_dir = '181023 M58 Ruleswitching'; 
expData(i).logfile = 'M58_RULESWITCHING_1810231352.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=21;
expData(i).sub_dir = '181025 M58 Ruleswitching'; 
expData(i).logfile = 'M58_RULESWITCHING_1810251553.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=22;
expData(i).sub_dir = '181030 M58 Ruleswitching'; 
expData(i).logfile = 'M58_RULESWITCHING_1810301204.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;

i=23;
expData(i).sub_dir = '181016 M59 RuleSwitching'; 
expData(i).logfile = 'M59_RULESWITCHING_1810161240.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=24;
expData(i).sub_dir = '181017 M59 RuleSwitching'; 
expData(i).logfile = 'M59_RULESWITCHING_1810171336.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=25;
expData(i).sub_dir = '181019 M59 Ruleswitching'; 
expData(i).logfile = 'M59_RULESWITCHING_1810191524.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=26;
expData(i).sub_dir = '181024 M59 Ruleswitching'; 
expData(i).logfile = 'M59_RULESWITCHING_1810241348.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=27;
expData(i).sub_dir = '181025 M59 Ruleswitching'; 
expData(i).logfile = 'M59_RULESWITCHING_1810251151.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;

i=28;
expData(i).sub_dir = '181016 M60 RuleSwitching'; 
expData(i).logfile = 'M60_RULESWITCHING_1810161547.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=29;
expData(i).sub_dir = '181023 M60 Ruleswitching'; 
expData(i).logfile = 'M60_RULESWITCHING_1810231536.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=30;
expData(i).sub_dir = '181025 M60 Ruleswitching'; 
expData(i).logfile = 'M60_RULESWITCHING_1810251345.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=31;
expData(i).sub_dir = '181026 M60 Ruleswitching'; 
expData(i).logfile = 'M60_RULESWITCHING_1810261517.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=32;
expData(i).sub_dir = '181030 M60 Ruleswitching'; 
expData(i).logfile = 'M60_RULESWITCHING_1810301348.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;

i=33;
expData(i).sub_dir = '181027 M61 Ruleswitching'; 
expData(i).logfile = 'M61_RULESWITCHING_1810271430.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=34;
expData(i).sub_dir = '181030 M61 Ruleswitching'; 
expData(i).logfile = 'M61_RULESWITCHING_1810301537.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;
i=35;
expData(i).sub_dir = '181031 M61 Ruleswitching'; 
expData(i).logfile = 'M61_RULESWITCHING_1810311203.log';
expData(i).cellType = 'VIP'; %Cell-type label 
expData(i).npCorrFactor = 0;

%% PV+ Interneurons (N=11?)
%Z-drift problematic, especially in sessions from M42 & M43. 
%Add field: expData(i).excludeFrames used for specifying frames encompassing z-drift corrections. 
%Modify calc_dFF to set as NaN, and then separately calculating dF/F for segments bounded by NaN...

%% CamKIIa+ Neurons (N=23)

%% Get ROI directories

for i = 1:numel(expData)
    dir_list = dir(fullfile(dirs.data,expData(i).sub_dir,'ROI*'));
    expData(i).roi_dir = dir_list.name; %Full path to ROI directory
end

  
