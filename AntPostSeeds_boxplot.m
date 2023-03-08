%% Homotopic vs. non-homotopic seeds
% HypoxiaLevels = {'Normoxia_1','Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2'};

function AntPostSeeds_boxplot(HypoxiaLevels, GSR, Conditions)
% Conditions can be diff, hypox or before. 
%do you want to take the raw correlation values or the differences?
% Give input with the {}
%     Conditions = {'Before', 'Hypox', 'Diff'};

if ~exist('Conditions', 'var')
    Conditions = {'Diff'};
end

if ~exist('GSR', 'var')
    GSR = 0;
end

for index1 = 1:size(Conditions, 2)
    Condition = Conditions{index1};

%% Get average correlation homotopic and non-homotopic seeds per mouse per acq
    
for ind = 1:size(HypoxiaLevels,2)
    HypoxiaLevel = HypoxiaLevels{ind};
    MiceWithin = [];
    MiceBetween = [];
    
    % Get right statistics .mat file
    if matches(Condition, 'Diff') && GSR == 1
        TmpHypox = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox.mat']);
        TmpBefore = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before.mat']);
        
    elseif matches(Condition, 'Diff') && GSR == 0
        TmpHypox = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox_NoGSR.mat']);
        TmpBefore = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before_NoGSR.mat']);
        
    elseif GSR == 1
        Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_' Condition '.mat']);
    elseif GSR == 0
        Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_' Condition '_NoGSR.mat']);
    end
    
    % if working with difference, substract before from hypox
    if exist('TmpHypox', 'Var')
        Name = fieldnames(TmpBefore);
        eval(['CorrValuesBefore = TmpBefore.' Name{:} ';']);
        Name = fieldnames(TmpHypox);
        eval(['CorrValuesHypox = TmpHypox.' Name{:} ';']);
        CorrValues = CorrValuesHypox - CorrValuesBefore;
    else
        Name = fieldnames(Tmp);
        eval(['CorrValues = Tmp.' Name{:} ';']);
    end
    
    clear Tmp Name TmpHypox TmpBefore CorrValuesBefore CorrValuesHypox 
    
    % group within areas
    for index = 1:size(CorrValues, 3) %go per mouse
        MouseWithin = [CorrValues(1,4,index), CorrValues(1,5,index), CorrValues(1,8,index),...
            CorrValues(2,3,index), CorrValues(2,6,index), CorrValues(2,7,index),...
            CorrValues(3,6,index), CorrValues(3,7,index),...
            CorrValues(4,5,index), CorrValues(4,8,index),...
            CorrValues(5,8,index), ...
            CorrValues(6,7,index)];

        MiceWithin(:,end+1) = MouseWithin;
    end
    
    % group betwen areaas
    for index = 1:size(CorrValues, 3)
        MouseBetween = [CorrValues(1,2,index), CorrValues(1,3,index), CorrValues(1,6,index), CorrValues(1,7,index),...
            CorrValues(2,4,index), CorrValues(2,5,index), CorrValues(2,8,index),...
            CorrValues(3,4,index), CorrValues(3,5,index), CorrValues(3,8,index),...
            CorrValues(4,6,index), CorrValues(4,7,index),...
            CorrValues(5,6,index), CorrValues(5,7,index),...
            CorrValues(6,8,index),...
            CorrValues(7,8,index)];
        MiceBetween(:,end+1) = MouseBetween; %this will gather the mice per level
    end
    
%     eval([HypoxiaLevel '_Homotopic = MiceHomotopic;']);
%     eval([HypoxiaLevel '_NonHomotopic = MiceNonHomotopic;']);
MiceWithin = reshape(MiceWithin, [], 1);
MiceBetween = reshape(MiceBetween, [], 1);
Group1 = repmat({'Within'}, size(MiceWithin));
Group2 = repmat({'Between'}, size(MiceBetween));

Groups = [Group1; Group2];
Corr = [MiceWithin; MiceBetween];

HLevel = repmat({HypoxiaLevel}, size(Corr));

if ~exist('BoxplotTable', 'var')
    BoxplotTable = table(Corr, Groups, HLevel);
else
    AddData = table(Corr, Groups, HLevel);
    BoxplotTable = [BoxplotTable; AddData];
end
end

BoxplotTable.HLevel = categorical(BoxplotTable.HLevel, HypoxiaLevels);

clear MiceBetween MiceWithin HypoxiaLevel MouseWithin ...
    MouseBetween ind index CorrValues AddData Group1 Group2 Groups ...
    HLevel Corr

% to plot
f = figure('InvertHardcopy','off','Color',[1 1 1]);

boxchart(BoxplotTable.HLevel, BoxplotTable.Corr, 'GroupByColor', BoxplotTable.Groups, ...
    'MarkerStyle', '.', 'LineWidth', 2, 'BoxWidth', 0.75)

legend({'Between areas', 'Within area'},...
    'FontSize', 13)
labels = {'Normoxia', '12%', '10%', '8%', '8%'};
xticks('auto');
xticklabels(labels);
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax,'FontSize', 18, 'FontWeight', 'bold', 'Linewidth', 2);
xlabel('Oxygen Level')
ylabel('Change in correlation')
f.Position = [10 10 1500 700]; %for size of screen before saving

%line at zero
% hAx = gca;
% xtk = hAx.XTick;
% hold on
% hL = plot(xtk, zeros(size(xtk)));

%% Save
if GSR == 1
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/AreaSeeds_Boxplot.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/AreaSeeds_Boxplot.tiff'], 'tiff');
else
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/AreaSeeds_Boxplot_NoGSR.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/AreaSeeds_Boxplot_NoGSR.tiff'], 'tiff');
end
end
close all

%% stats
BoxplotTable.HLevel = string(BoxplotTable.HLevel);
for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    eval([HypoxiaLevel '_between = [];']);
    
    for ind = 1:size(BoxplotTable, 1)
        if matches(BoxplotTable.Groups(ind), 'Between') && matches(BoxplotTable.HLevel(ind), HypoxiaLevel)
             eval([HypoxiaLevel '_between(:, end+1) = BoxplotTable.Corr(ind);']);
        end
    end
end

for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    eval([HypoxiaLevel '_within = [];']);
    
    for ind = 1:size(BoxplotTable, 1)
        if matches(BoxplotTable.Groups(ind), 'Within') && matches(BoxplotTable.HLevel(ind), HypoxiaLevel)
             eval([HypoxiaLevel '_within(:, end+1) = BoxplotTable.Corr(ind);']);
        end
    end
end

p_betweens = [];
p_withins = [];

for index = 1:size(HypoxiaLevels,2)
    HypoxiaLevel = HypoxiaLevels{index};
    eval(['[~, pbet] = ttest(' HypoxiaLevel '_between);'])
    eval(['[~, pwith] = ttest(' HypoxiaLevel '_within);'])
    disp([HypoxiaLevel ' p between: ' num2str(pbet)])
    disp([HypoxiaLevel ' p within: ' num2str(pwith)])
    p_betweens(:,end+1) = pbet;
    p_withins(:,end+1) = pwith;
end

p_values = [p_betweens p_withins];
q_values = mafdr(p_values,'BHFDR', 'true');


end