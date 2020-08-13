%For each session, load decoding results and add/edit entry with new parameters...
clearvars;
[dirs, expData] = expData_RuleSwitching(pathlist_RuleSwitching);
[~,~,~,mat_file,params] = params_RuleSwitching(dirs,expData);

%Name and define new decode type
params.decode.decode_type = {'prior_choice_action'}; %Cell array of N = one or more decode types
params.decode.trialSpec = {...
    {'priorLeft','priorHit','action'},...
    {'priorRight','priorHit','action'}}; %N-by-2 cell array of trial specifiers; comparisons are trialSpec{i,1} vs. trialSpec{i,2}

%***ADD PROGRESS BAR next time!
 f = waitbar(0,'');
for i = 1:numel(expData)
    % Display waitbar
    msg = ['Session ' num2str(i) '/' num2str(numel(expData)) '...'];
    waitbar(i/numel(expData),f,msg);
    % Load data
    load(mat_file.img_beh(i),'trialDFF','trials','cellID');
    load(mat_file.results(i),'bootAvg','decode');
    % Trial averaging
%     new_bootAvg = calc_trialAvgFluo(trialDFF, trials, params.decode);
%     fields = fieldnames(new_bootAvg);
%     fields = fields(~ismember(fields,'t'));
%     for j = 1:numel(fields)
%         bootAvg.(fields{j}) = new_bootAvg.(fields{j});
%     end
%     save(mat_file.results(i),'bootAvg','-append');
        
    % Decode choice, outcome, and rule from single-units
    new_decode = calc_selectivity(trialDFF,trials,params.decode);
    for j = 1:numel(params.decode.decode_type)
        decode.(params.decode.decode_type{j}) = new_decode.(params.decode.decode_type{j});
    end
    save(mat_file.results(i),'decode','-append');
    clearvars trialDFF trials bootAvg new_bootAvg decode new_decode;
end
