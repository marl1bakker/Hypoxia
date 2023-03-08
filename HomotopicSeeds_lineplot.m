%% Homotopic vs. non-homotopic seeds
% HypoxiaLevels = {'Normoxia_1','Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2'};

%% Per mouse

function HomotopicSeeds_lineplot(HypoxiaLevels, GSR, Conditions)
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
Homotopic = [];
NonHomotopic = [];
    
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
        MouseHomotopic = mean(MouseHomotopic);
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
        
        MouseNonHomotopic = mean(MouseNonHomotopic, 'all', 'omitnan');
        MiceNonHomotopic(:,end+1) = MouseNonHomotopic; %this will gather the mice per level
    end
    
    Homotopic = [Homotopic; MiceHomotopic]; % this is to add all hypoxia levels
    NonHomotopic = [NonHomotopic; MiceNonHomotopic];

end
%(Non)Homotopic is organized as hypoxialevels * mice
clear MiceNonHomotopic MiceHomotopic HypoxiaLevel MouseHomotopic ...
    MouseNonHomotopic ind index CorrValues 

% to plot
f = figure('InvertHardcopy','off','Color',[1 1 1]);
p1 = plot(Homotopic, 'Color', 'green',...
    'LineWidth',2);
hold on
p2 = plot(NonHomotopic, 'Color', 'red',...
    'LineWidth', 2);
legend([p1(1,1) p2(1,1)], {'Homotopic', 'Non-Homotopic'},...
    'FontSize', 13)
labels = {'Normoxia', '12%', '10%', '8%', '8%'};
xticks(1:5);
xticklabels(labels);
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax,'FontSize', 18, 'FontWeight', 'bold', 'Linewidth', 2);
xlabel('Oxygen Level')
ylabel('Change in correlation')
f.Position = [10 10 1500 700]; %for size of screen before saving
title('Per mouse')

%% Save
if GSR == 1
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerMouse.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerMouse.tiff'], 'tiff');
else
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerMouse_NoGSR.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerMouse_NoGSR.tiff'], 'tiff');
end
end

close all
clear ax f Homotopic index1 labels NonHomotopic p1 p2






%%
%% Per Seed pair

for index1 = 1:size(Conditions, 2)
    Condition = Conditions{index1};

%% Get average correlation homotopic and non-homotopic seeds per mouse per acq
Homotopic = [];
NonHomotopic = [];
    
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
        MiceHomotopic(:,end+1) = MouseHomotopic;
    end
    
    % group non homotopic
    for index = 1:size(CorrValues, 3)
        CorrValues = reshape(CorrValues, 1, []);
        MouseNonHomotopic = CorrValues([2:4, 6:8, 11:13, 15:16, 20:22, ...
            24, 29:31, 38:40, 47:48, 56]);
        MiceNonHomotopic(:,end+1) = MouseNonHomotopic; %this will gather the mice per level
    end
    %now have seeds x mice, want to average over mice
    MiceNonHomotopic = mean(MiceNonHomotopic, 2);
    MiceHomotopic = mean(MiceHomotopic, 2);
    
    %will become hypoxialevels x seeds
    Homotopic = [Homotopic; MiceHomotopic']; % this is to add all hypoxia levels
    NonHomotopic = [NonHomotopic; MiceNonHomotopic'];

end
%(Non)Homotopic is organized as hypoxialevels * mice
clear MiceNonHomotopic MiceHomotopic HypoxiaLevel MouseHomotopic ...
    MouseNonHomotopic ind index CorrValues 

% to plot
f = figure('InvertHardcopy','off','Color',[1 1 1]);
p1 = plot(Homotopic, 'Color', 'green',...
    'LineWidth',2);
hold on
p2 = plot(NonHomotopic, 'Color', 'red',...
    'LineWidth', 2);
legend([p1(1,1) p2(1,1)], {'Homotopic', 'Non-Homotopic'},...
    'FontSize', 13, 'Location', 'southwest')
labels = {'Normoxia', '12%', '10%', '8%', '8%'};
xticks(1:5);
xticklabels(labels);
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax,'FontSize', 18, 'FontWeight', 'bold', 'Linewidth', 2);
xlabel('Oxygen Level')
ylabel('Change in correlation')
f.Position = [10 10 1500 700]; %for size of screen before saving
title('Per seed')


%% Save
if GSR == 1
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerSeed.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerSeed.tiff'], 'tiff');
else
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerSeed_NoGSR.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerSeed_NoGSR.tiff'], 'tiff');
end

close all
end






%% Boxplots
for index1 = 1:size(Conditions, 2)
    Condition = Conditions{index1};

%% Get average correlation homotopic and non-homotopic seeds per mouse per acq
Homotopic = [];
NonHomotopic = [];
    
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
        MouseHomotopic = mean(MouseHomotopic);
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
        
        MouseNonHomotopic = mean(MouseNonHomotopic, 'all', 'omitnan');
        MiceNonHomotopic(:,end+1) = MouseNonHomotopic; %this will gather the mice per level
    end
    
    Homotopic = [Homotopic; MiceHomotopic]; % this is to add all hypoxia levels
    NonHomotopic = [NonHomotopic; MiceNonHomotopic];

end
%(Non)Homotopic is organized as hypoxialevels * mice
clear MiceNonHomotopic MiceHomotopic HypoxiaLevel MouseHomotopic ...
    MouseNonHomotopic ind index CorrValues 

% to plot
f = figure('InvertHardcopy','off','Color',[1 1 1]);
p1 = plot(Homotopic, 'Color', 'green',...
    'LineWidth',2);
hold on
p2 = plot(NonHomotopic, 'Color', 'red',...
    'LineWidth', 2);
legend([p1(1,1) p2(1,1)], {'Homotopic', 'Non-Homotopic'},...
    'FontSize', 13)
labels = {'Normoxia', '12%', '10%', '8%', '8%'};
xticks(1:5);
xticklabels(labels);
ax = get(gca,'XTickLabel');
set(gca,'XTickLabel',ax,'FontSize', 18, 'FontWeight', 'bold', 'Linewidth', 2);
xlabel('Oxygen Level')
ylabel('Change in correlation')
f.Position = [10 10 1500 700]; %for size of screen before saving
title('Per mouse')

%% Save
if GSR == 1
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerMouse.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerMouse.tiff'], 'tiff');
else
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerMouse_NoGSR.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/HomotopicSeeds/HomotopicSeeds_PerMouse_NoGSR.tiff'], 'tiff');
end
end

close all
clear ax f Homotopic index1 labels NonHomotopic p1 p2


end