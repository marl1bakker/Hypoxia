%% Statistics on plateuas
% 11-3-2022
% Will ask you to estimate where the plateau is, and then gives you the
% mean, the SEM and the comparison to baseline values.
%
% HypoxiaLevels, Glist: see HypoxPipelineCombi
% Data: the data you want to do stats on
% Prompt: 1 by default, if 0 will give 14,5 - 19,5 min 

function [AveragePlateau, AverageBaseline, pvalues, qvalues] = ...
    PlateauStats(HypoxiaLevels, Glist, Data, Prompt)

if ~exist('Prompt', 'var')
    Prompt = 1;
end

pvalues = [];
AveragePlateau = [];
AverageBaseline = [];


for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    
    DataPerHlevel = [];
    
    % Get data per hypoxia level
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        if ~isempty(idx)
            DataPerHlevel = [DataPerHlevel; Data(ind, :)];
        end
    end
    
    %% Prompt
    if Prompt == 1
    %questionbox to indicate the location of the first peak and the plateau
    prompt = {'Start of plateau in frames', 'End of plateau in frames',...
        'Start of baseline in frames', 'End of baseline in frames (10800 is 9 min)'};
    dlgtitle = 'Stats Input';
    dimensions = [1 35];
    definput = {'18000', '24000', ...
        'Based on plateau length', '10800'}; %BASELINE BASIS - ends at 9 min
    opts.WindowStyle = 'normal';
    answer = inputdlg(prompt,dlgtitle,dimensions,definput, opts);
    clear prompt dlgtitle dimensions definput opts
        startbaseline = 4.5*20*60;
        endbaseline = 9.5*20*60;
        startplateau = 14.5*20*60;
        endplateau = 19.5*20*60;
    startplateau = str2num(answer{1});
    endplateau = str2num(answer{2});
    endbaseline = str2num(answer{4});
    
    if answer{3} == 'Based on plateau length'
        startbaseline = endbaseline - (endplateau-startplateau); %make sure plateau and baseline are same lenght
        if startbaseline < 1
            startbaseline = 1;
            disp(['Baseline start adjusted to 1. Baseline might be shorter in duration than plateau for ' HypoxiaLevel])
        end
    else
        startbaseline = str2num(answer{3});
    end
    
    else
        startbaseline = 4.5*20*60;
        endbaseline = 9.5*20*60;
        startplateau = 14.5*20*60;
        endplateau = 19.5*20*60;
    end
    %% Stats
    yMean = mean(DataPerHlevel, 1, 'omitnan'); %get mean of all animals
    
    averageplateau = mean(yMean(startplateau:endplateau), 2, 'omitnan');
    stdplateau = std(yMean(startplateau:endplateau));
    
    AveragePlateau = [AveragePlateau; averageplateau, stdplateau];
    
    
    averagebaseline = mean(yMean(startbaseline:endbaseline), 2, 'omitnan');
    stdbaseline = std(yMean(startbaseline:endbaseline));
    
    AverageBaseline = [AverageBaseline; averagebaseline, stdbaseline];
    
    %wilcox signed rank test
    differences = DataPerHlevel(:, startplateau:endplateau) - DataPerHlevel(:, startbaseline:endbaseline);
    differences = mean(differences, 2); %make sure you have the average of each mouse
    [p, ~, ~] = signrank(differences);
    pvalues = [pvalues; p];
    
    %student t test
%     [~,p] = ttest(mean(DataPerHlevel(:, startplateau:endplateau),2), ...
%         mean(DataPerHlevel(:, startbaseline:endbaseline),2));
%     pvalues = [pvalues; p];
    % UNSURE ABOUT P VALUES
    
end
    qvalues = mafdr(reshape(pvalues, [], 1),'BHFDR', 'true');
end