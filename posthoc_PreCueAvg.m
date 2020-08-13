function stats_struct = posthoc_preCueAvg( stats_struct, decode_type, cellTypes, varargin )

idx = stats_struct.time<0; %Pre-cue times
for i=1:numel(cellTypes)
    if numel(varargin)>1 %eg, varargin = {["diffNull"],["selMag_t"]}
        data = mean(stats_struct.(decode_type).(cellTypes(i)).(varargin{1}).(varargin{2}).data(:,idx),2);
        expID = stats_struct.(decode_type).(cellTypes(i)).(varargin{1}).(varargin{2}).expID;
        stats_struct.(decode_type).(cellTypes(i)).(varargin{1}).(strjoin(["preCueAvg_",varargin{2}],'')) =...
            calcStats(data,expID);
    else %eg, varargin = {"selMag_t"}
        data = mean(stats_struct.(decode_type).(cellTypes(i)).(varargin{1}).data(:,idx),2);
        expID = stats_struct.(decode_type).(cellTypes(i)).(varargin{1}).expID;
        stats_struct.(decode_type).(cellTypes(i)).(strjoin(["preCueAvg_",varargin{1}],'')) =...
            calcStats(data,expID);
    end
end
