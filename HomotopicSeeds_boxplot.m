%% Homotopic vs. non-homotopic seeds
% HypoxiaLevels = {'Normoxia_1','Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2'};

function HomotopicSeeds_boxplot(HypoxiaLevels, GSR, Conditions)
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
    MiceHomotopic = [];
    MiceNonHomotopic = [];
    
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
    
    % group homotopic
    for index = 1:size(CorrValues, 3) %go per mouse
        MouseHomotopic = [CorrValues(1,5,index), CorrValues(2,6,index), ...
            CorrValues(3,7,index), CorrValues(4,8,index)];
%         MouseHomotopic = mean(MouseHomotopic);
        MiceHomotopic(:,end+1) = MouseHomotopic;
    end
    
    % group non homotopic
    for index = 1:size(CorrValues, 3)
        MouseNonHomotopic = tril(CorrValues(:,:,index));
        MouseNonHomotopic(5,1) = NaN;
        MouseNonHomotopic(6,2) = NaN;
        MouseNonHomotopic(7,3) = NaN;
        MouseNonHomotopic(8,4) = NaN;
        MouseNonHomotopic(MouseNonHomotopic == 1) = NaN;
        MouseNonHomotopic = reshape(MouseNonHomotopic, 1, []);
%         MouseNonHomotopic = mean(MouseNonHomotopic, 'all', 'omitnan');
        MiceNonHomotopic(:,end+1) = MouseNonHomotopic; %this will gather the mice per level
    end
    
%     eval([HypoxiaLevel '_Homotopic = MiceHomotopic;']);
%     eval([HypoxiaLevel '_NonHomotopic = MiceNonHomotopic;']);
MiceHomotopic = reshape(MiceHomotopic, [], 1);
MiceNonHomotopic = reshape(MiceNonHomotopic, [], 1);
Group1 = repmat({'Homotopic'}, size(MiceHomotopic));
Group2 = repmat({'NonHomotopic'}, size(MiceNonHomotopic));

Groups = [Group1; Group2];
Corr = [MiceHomotopic; MiceNonHomotopic];

HLevel = repmat({HypoxiaLevel}, size(Corr));

if ~exist('BoxplotTable', 'var')
    BoxplotTable = table(Corr, Groups, HLevel);
else
    AddData = table(Corr, Groups, HLevel);
    BoxplotTable = [BoxplotTable; AddData];
end
end

BoxplotTable.HLevel = categorical(BoxplotTable.HLevel, HypoxiaLevels);

clear MiceNonHomotopic MiceHomotopic HypoxiaLevel MouseHomotopic ...
    MouseNonHomotopic ind index CorrValues AddData Group1 Group2 Groups ...
    HLevel Corr

% to plot
f = figure('InvertHardcopy','off','Color',[1 1 1]);

boxchart(BoxplotTable.HLevel, BoxplotTable.Corr, 'GroupByColor', BoxplotTable.Groups, ...
    'MarkerStyle', '.', 'LineWidth', 2, 'BoxWidth', 0.75)

legend({'Homotopic', 'Non-Homotopic'},...
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
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_Boxplot.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_Boxplot.tiff'], 'tiff');
else
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_Boxplot_NoGSR.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_Boxplot_NoGSR.tiff'], 'tiff');
end
end

close all

end