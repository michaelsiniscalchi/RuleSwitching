function ax = list_panelSpecs( figID, params )

p = params.figs.all;

switch figID
    case 'bootAvg'
        
        %Specify struct 'ax' containing variables and plotting params for each figure panel:
        trialSpec = params.bootAvg.trialSpec;
        for i=1:size(trialSpec,1)
            ax(i).trialSpec  = {trialSpec{i,1},trialSpec{i,2}}; %#ok<AGROW> %Refer to params.bootAvg.trialSpec
        end
        
        ax(1).title      = 'Choice (sound rule)';
        ax(1).color      = {p.colors.left,p.colors.right}; %Choice: left/hit/sound vs right/hit/sound
        ax(1).lineStyle  = {'-','-'};
        ax(2).title      = 'Choice (action rule)';
        ax(2).color      = {p.colors.left,p.colors.right}; %Choice: left/hit/sound vs right/hit/sound
        ax(2).lineStyle  = {'-','-'};
        ax(3).title      = 'Prior choice (sound)';
        ax(3).color      = {p.colors.left,p.colors.right}; %Choice: left/hit/sound vs right/hit/sound
        ax(3).lineStyle  = {'-','-'};
        ax(4).title      = 'Prior choice (action)';
        ax(4).color      = {p.colors.left,p.colors.right}; %Choice: left/hit/sound vs right/hit/sound
        ax(4).lineStyle  = {'-','-'};
        ax(5).title      = 'Outcome';
        ax(5).color      = {p.colors.hit,p.colors.err}; %Outcome: hit/priorHit vs err/priorHit
        ax(5).lineStyle  = {'-','-'};
        ax(6).title      = 'Prior outcome';
        ax(6).color      = {p.colors.hit,p.colors.err}; %Outcome: hit/priorHit vs err/priorHit
        ax(6).lineStyle  = {'-','-'};
        ax(7).title      = 'Rule (left choice)';
        ax(7).color      = {p.colors.data,p.colors.left}; %Rule: left/upsweep/sound vs left/upsweep/actionL
        ax(7).lineStyle  = {'-','-'};
        ax(8).title      = 'Rule (right choice)';
        ax(8).color      = {p.colors.data,p.colors.right}; %Rule: right/downsweep/sound vs right/downsweep/actionR
        ax(8).lineStyle  = {'-','-'};
        
    case 'decode_single_units'
        %Specify struct 'ax' containing variables and plotting params for each figure panel:
        ax(1).title      = 'Choice (sound)';
        ax(1).color      = p.colors.data;
        ax(2).title      = 'Choice (action)';
        ax(2).color      = p.colors.data;
        ax(3).title      = 'Prior choice';
        ax(3).color      = p.colors.data;
        ax(4).title      = 'Prior choice (action)';
        ax(4).color      = p.colors.data;
        ax(5).title      = 'Outcome';
        ax(5).color      = p.colors.hit;
        ax(6).title      = 'Prior outcome';
        ax(6).color      = p.colors.hit;
        ax(7).title      = 'Rule (left choice)';
        ax(7).color      = p.colors.actionL;
        ax(8).title      = 'Rule (right choice)';
        ax(8).color      = p.colors.actionR;
        
end