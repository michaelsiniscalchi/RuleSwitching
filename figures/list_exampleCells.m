function [ expList, cellIDs ] = list_exampleCells( figID )

switch figID
    case 'fovProj'
        
    case 'timeseries'
        expList = {...
            '171109 M51 RuleSwitching';...SST {'007','013','014','018','021'} (cell IDs)
            '181010 M57 RuleSwitching';...VIP {'002','004','009','013','032'} (cell IDs)
            '171104 M42 RuleSwitching';...PV  {'004','005','013','018','021'} (cell IDs)
            '180831 M55 RuleSwitching'}; %PYR {'140','141','142','143','144'} (cell IDs)
        cellIDs = {...
            {'007','014','018','021'};...
            {'002','004','007','013'};
            {'004','013','017','018'};
            {'005','007','014','030'}};
        
    case 'bootAvg'
        temp = {...
            %Choice cells
            '171013 M48 RuleSwitching',{'011'};... %171013 M48 RuleSwitching_cell011_bootavg CHOICE & OUTCOME
            '181016 M60 RuleSwitching',{'011'};... %181016 M60 RuleSwitching_cell011_bootavg CHOICE & RULE
            '171019 M43 RuleSwitching',{'013'};... %171019 M43 RuleSwitching_cell013_bootavg
            '180921 M56 RuleSwitching',{'005'};... %180921 M56 RuleSwitching_cell005_bootavg CHOICE & OUTCOME
            %Outcome cells
            '180927 M57 RuleSwitching',{'001'};... %180927 M57 RuleSwitching_cell001_bootavg
            '171113 M42 RuleSwitching',{'011'};... %171113 M42 RuleSwitching_cell011_bootavg
            %Rule cells 171101 M49 RuleSwitching_cell008_bootavg
            '171114 M47 RuleSwitching',{'031'};... %171114 M47 RuleSwitching_cell031_bootavg
            '171101 M49 RuleSwitching',{'008'};... %171101 M49 RuleSwitching_cell008_bootavg
            '171112 M49 RuleSwitching',{'011'};... %171112 M49 RuleSwitching_cell011_bootavg
            '171102 M43 RuleSwitching',{'006'};... %171102 M43 RuleSwitching_cell006_bootavg
            '180905 M55 RuleSwitching',{'113'}};   %180905 M55 RuleSwitching_cell113_bootavg
        expList = temp(:,1);
        cellIDs = temp(:,2);
        
    case 'timeAvg' %Use all cells for now...
        
end

%---------------------------------------------------------------------------------------------------
% Originally like this:
%
%         expList = {...
%             '171109 M51 RuleSwitching';...SST {'007','013','014','018','021'} (cell IDs)
%             '181010 M57 RuleSwitching';...VIP {'002','004','009','013','032'} (cell IDs)
%             '171104 M42 RuleSwitching';...PV  {'004','005','013','018','021'} (cell IDs)
%             '180831 M55 RuleSwitching'}; %PYR {'140','141','142','143','144'} (cell IDs)
%         cellIDs = {...
%             {'007','014','018','021'};...
%             {'002','004','007','013'};
%             {'004','013','017','018'};
%             {'005','007','014','030'}};