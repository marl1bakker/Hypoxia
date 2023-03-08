% SeedPairs = {{'Mot R', 'Sen L'}, {'Vis L', 'Vis R'}, {'Mot R', 'Sen R'}};
%values from combicorrmatrices.m
% Plot on laptop! different images than on ubuntu

function PlotSeedPairsOverNormLevels(SeedPairs, GSR)

if ~exist('GSR', 'var')
    GSR = 1;
end

ROIlabels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
% HypoxiaLevels = {'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2'};
HypoxiaLevels = {'Normoxia_1','Hypox_12', 'Normoxia_2', 'Hypox_10', 'Normoxia_3',...
    'Hypox_8_1', 'Normoxia_4', 'Hypox_8_2'};

ToPlotPos = [];
ToPlotNeg = [];
StdevsPos = [];
StdevsNeg = [];
SEMsPos = [];
SEMsNeg = [];
LegendPos = {};
LegendNeg = {};

for index = 1:size(SeedPairs, 2)
    SeedPair = SeedPairs{index};
    Seedindex1 = find(contains(ROIlabels, SeedPair{1}));
    Seedindex2 = find(contains(ROIlabels, SeedPair{2}));
    
    Correlations = zeros(size(HypoxiaLevels,2),1);
    Stdevs = zeros(size(HypoxiaLevels,2),1);
    SEMs = zeros(size(HypoxiaLevels,2),1);
    for ind = 1:size(HypoxiaLevels, 2)
        if GSR == 1
            load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevels{ind} '_Before.mat']);
        else
            load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevels{ind} '_Before_NoGSR.mat']);
        end
        SeedPairCorr = mean(CorrBefore(Seedindex1, Seedindex2, :),3, 'omitnan');
        Correlations(ind) = SeedPairCorr;
        Stdevs(ind) = std(CorrBefore(Seedindex1, Seedindex2,:), 'omitnan');
        SEMs(ind) = Stdevs(ind)/sqrt(length(CorrBefore(Seedindex1, Seedindex2,:)));
    end
    
    if mean(mean(Correlations,1, 'omitnan'),2, 'omitnan') > 0
        ToPlotPos = [ToPlotPos; Correlations'];
        LegendPos = [LegendPos, {[SeedPair{1} ' - ' SeedPair{2}]}];
        StdevsPos = [StdevsPos; Stdevs'];
        SEMsPos = [SEMsPos; SEMs'];
    else
        ToPlotNeg = [ToPlotNeg; Correlations'];
        LegendNeg = [LegendNeg, {[SeedPair{1} ' - ' SeedPair{2}]}];
        StdevsNeg = [StdevsNeg; Stdevs'];
        SEMsNeg = [SEMsNeg; SEMs'];
    end
    
end
    
%plot Pos
f = figure('InvertHardcopy','off','Color',[1 1 1]);
axes1 = axes;
hold(axes1,'on');
set(axes1,'FontSize',18,'FontWeight','bold','LineWidth',2);
errorbar(ToPlotPos', StdevsPos', '-o', 'LineWidth', 2)
% errorbar(ToPlotPos', SEMsPos', '-o', 'LineWidth', 2)
% plot(ToPlotPos', '-o', 'LineWidth', 2)
ylim([-0.1 1])
xlim([1 8])
f.Position = [10 10 910 700]; %for size of screen before saving
if GSR == 1
    lgd = legend(LegendPos, 'FontSize', 13, 'Location', 'northwest', ...
        'Orientation', 'vertical');
else
    lgd = legend(LegendPos, 'FontSize', 13, 'Location', 'southwest', ...
        'Orientation', 'vertical'); %to make sure it's not over the data
end
lgd.NumColumns = 2;
xticks(1:8);
title('Positive Seed Pairs');

if GSR == 1
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPairs/SeedPairCorr_Pos_NormLevels.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPairs/SeedPairCorr_Pos_NormLevels.tiff'], 'tiff');
else
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPairs/SeedPairCorr_Pos_NormLevels_NoGSR.eps'], 'epsc');
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPairs/SeedPairCorr_Pos_NormLevels_NoGSR.tiff'], 'tiff');
end
close all;

%     plot Neg
if GSR == 1 % without GSR there's no negative
    f = figure('InvertHardcopy','off','Color',[1 1 1]);
    axes1 = axes;
    hold(axes1,'on');
    set(axes1,'FontSize',18,'FontWeight','bold','LineWidth',2);
    % plot(ToPlotNeg', '-o', 'LineWidth', 2)
    errorbar(ToPlotNeg', StdevsNeg', '-o', 'LineWidth', 2)
    % errorbar(ToPlotNeg', SEMsNeg', '-o', 'LineWidth', 2)
    ylim([-1 0])
    xlim([1 8])
    f.Position = [10 10 910 700]; %for size of screen before saving
    lgd = legend(LegendNeg, 'FontSize', 13, 'Location', 'southwest', ...
        'Orientation', 'vertical');
    lgd.NumColumns = 2;
    xticks(1:8);
    title('Negative Seed Pairs');
    
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/SeedPairs/SeedPairCorr_Neg_NormLevels.eps'], 'epsc');
else
    
    close all;
end
end
