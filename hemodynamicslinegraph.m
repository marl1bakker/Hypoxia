%% hemodynamics linegraph

function hemodynamicslinegraph(HypoxiaLevels, Glist, TitleList, ManualInput)
if ~exist('ManualInput', 'var')
    ManualInput = 0;
end
if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/Hemodynamics/Hypox_8_1-mean.fig', 'file') )  
    disp('Hemodynamics plotting already done, exited function')
    return;
end
if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/Hemodynamics/Hypox_8_1-mean.fig', 'file') )  
    disp('Hemodynamics plotting already done, OVERWRITING FILES')
end

load('/media/mbakker/data1/Hypoxia/Hemodynamics/HbOmean.mat')
load('/media/mbakker/data1/Hypoxia/Hemodynamics/HbOmedian.mat')
load('/media/mbakker/data1/Hypoxia/Hemodynamics/HbRmean.mat')
load('/media/mbakker/data1/Hypoxia/Hemodynamics/HbRmedian.mat')
mean_HbT_list = mean_HbO_list + mean_HbR_list;
median_HbT_list = median_HbO_list + median_HbR_list;

if ~exist('TitleList', 'var')
    TitleList = HypoxiaLevels;
end

% % For stats
% PlateausHbOMean = [];
% PlateausHbRMean = [];
% PlateausHbTMean = [];
% PlateausHbOMedian = [];
% PlateausHbRMedian = [];
% PlateausHbTMedian = [];

for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};

    %% median
    HlevelHbO = [];
    HlevelHbR = [];
    HlevelHbT = [];
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        if ~isempty(idx)
            HlevelHbO = [HlevelHbO; median_HbO_list(ind, :)];
            HlevelHbR = [HlevelHbR; median_HbR_list(ind, :)];
            HlevelHbT = [HlevelHbT; median_HbT_list(ind, :)];
        end
    end

    %% Stats of plateau -- NEW
    % not saved anywhere, but if you want to know you can put a hold at the
    % end and check
%     yMeanHbO = mean(HlevelHbO, 1, 'omitnan');
%     PlateauHbO = mean(yMeanHbO(:,13200:24000),2); %get between 11 and 20 min
%     SEMHbO = mean((std(HlevelHbO(:,13200:24000), 1, 'omitnan')/sqrt(8)),2);
%     PlateausHbOMedian = [PlateausHbOMedian; PlateauHbO, SEMHbO];
%     
%     yMeanHbR = mean(HlevelHbR, 1, 'omitnan');
%     PlateauHbR = mean(yMeanHbR(:,13200:24000),2); 
%     SEMHbR = mean((std(HlevelHbR(:,13200:24000), 1, 'omitnan')/sqrt(8)),2);
%     PlateausHbRMedian = [PlateausHbRMedian; PlateauHbR, SEMHbR];
%     
%     yMeanHbT = mean(HlevelHbT, 1, 'omitnan');
%     PlateauHbT = mean(yMeanHbT(:,13200:24000),2); 
%         SEMHbT = mean((std(HlevelHbT(:,13200:24000), 1, 'omitnan')/sqrt(8)),2);
%     PlateausHbTMedian = [PlateausHbTMedian; PlateauHbT, SEMHbT];
%     
    
    %% graph
    x = linspace(0,40,48000); %x axis in min
    
    yMeanHbO = mean(HlevelHbO, 1, 'omitnan');
    yMeanHbO = movmedian(yMeanHbO, 200);
    ySEMHbO = std(HlevelHbO, 1, 'omitnan')/sqrt(8);
    ySEMHbO = movmedian(ySEMHbO, 200);
    CI95 = tinv([0.025 0.975], 8-1);
    yCI95HbO = bsxfun(@times,ySEMHbO, CI95(:));
    
    yMeanHbR = mean(HlevelHbR, 1, 'omitnan');
    yMeanHbR = movmedian(yMeanHbR, 200);
    ySEMHbR = std(HlevelHbR, 1, 'omitnan')/sqrt(8);
    ySEMHbR = movmedian(ySEMHbR, 200);
    yCI95HbR = bsxfun(@times,ySEMHbR, CI95(:));
    
    yMeanHbT = mean(HlevelHbT, 1, 'omitnan');
    yMeanHbT = movmedian(yMeanHbT, 200);
    ySEMHbT = std(HlevelHbT, 1, 'omitnan')/sqrt(8);
    ySEMHbT = movmedian(ySEMHbT, 200);
    yCI95HbT = bsxfun(@times,ySEMHbT, CI95(:));
    
    figure
    plot(x, yMeanHbO, 'Color','#A2142F')    
    ylim([-20 75])
    hold on
    plot(x, yMeanHbR, 'Color', '#0072BD')
    plot(x, yMeanHbT, 'Color','#77AC30')
    
    patch([x, fliplr(x)], [yMeanHbO + yCI95HbO(1,:) fliplr(yMeanHbO + yCI95HbO(2,:))], 'r' ,'EdgeColor','none', 'FaceAlpha',0.25)
    patch([x, fliplr(x)], [yMeanHbR + yCI95HbR(1,:) fliplr(yMeanHbR + yCI95HbR(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)
    patch([x, fliplr(x)], [yMeanHbT + yCI95HbT(1,:) fliplr(yMeanHbT + yCI95HbT(2,:))], 'g', 'EdgeColor','none', 'FaceAlpha',0.25)
    
    title([TitleList{index} ' - Median'])
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/Hemodynamics/' HypoxiaLevel '-median.png'])
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/Hemodynamics/' HypoxiaLevel '-median.fig'])
    
    close all
     %% mean
    HlevelHbO = [];
    HlevelHbR = [];
    HlevelHbT = [];
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        if ~isempty(idx)
            HlevelHbO = [HlevelHbO; mean_HbO_list(ind, :)];
            HlevelHbR = [HlevelHbR; mean_HbR_list(ind, :)];
            HlevelHbT = [HlevelHbT; mean_HbT_list(ind, :)];
        end
    end
    
%     %% Stats of plateau -- NEW
%     yMeanHbO = mean(HlevelHbO, 1, 'omitnan');
%     PlateauHbO = mean(yMeanHbO(:,16800:24000),2); %get between 11 and 20 min
%     SEMHbO = mean((std(HlevelHbO(:,16800:24000), 1, 'omitnan')/sqrt(8)),2);
%     PlateausHbOMean = [PlateausHbOMean; PlateauHbO, SEMHbO];
    
%     yMeanHbR = mean(HlevelHbR, 1, 'omitnan');
%     PlateauHbR = mean(yMeanHbR(:,13200:24000),2); 
%     SEMHbR = mean((std(HlevelHbR(:,13200:24000), 1, 'omitnan')/sqrt(8)),2);
%     PlateausHbRMean = [PlateausHbRMean; PlateauHbR, SEMHbR];
%     
%     yMeanHbT = mean(HlevelHbT, 1, 'omitnan');
%     PlateauHbT = mean(yMeanHbT(:,13200:24000),2); 
%         SEMHbT = mean((std(HlevelHbT(:,13200:24000), 1, 'omitnan')/sqrt(8)),2);
%     PlateausHbTMean = [PlateausHbTMean; PlateauHbT, SEMHbT];
    
    %% Graph
    x = linspace(0,40,48000); %x axis in min
    
    yMeanHbO = mean(HlevelHbO, 1, 'omitnan');
    yMeanHbO = movmedian(yMeanHbO, 200);
    ySEMHbO = std(HlevelHbO, 1, 'omitnan')/sqrt(8);
    ySEMHbO = movmedian(ySEMHbO, 200);
    CI95 = tinv([0.025 0.975], 8-1);
    yCI95HbO = bsxfun(@times,ySEMHbO, CI95(:));
    
    yMeanHbR = mean(HlevelHbR, 1, 'omitnan');
    yMeanHbR = movmedian(yMeanHbR, 200);
    ySEMHbR = std(HlevelHbR, 1, 'omitnan')/sqrt(8);
    ySEMHbR = movmedian(ySEMHbR, 200);
    yCI95HbR = bsxfun(@times,ySEMHbR, CI95(:));
    
    yMeanHbT = mean(HlevelHbT, 1, 'omitnan');
    yMeanHbT = movmedian(yMeanHbT, 200);
    ySEMHbT = std(HlevelHbT, 1, 'omitnan')/sqrt(8);
    ySEMHbT = movmedian(ySEMHbT, 200);
    yCI95HbT = bsxfun(@times,ySEMHbT, CI95(:));
    
%     %OLD
%     figure
%     plot(x, yMeanHbO, 'Color','#A2142F')    
%     ylim([-20 75])
%     hold on
%     plot(x, yMeanHbR, 'Color', '#0072BD')
%     plot(x, yMeanHbT, 'Color','#77AC30')
    
       %NEW
    f = figure('InvertHardcopy','off','Color',[1 1 1]);
    axes1 = axes;
    hold(axes1,'on');
    set(axes,'FontSize',14,'FontWeight','bold','LineWidth',2);
    plot(x, movmedian(yMeanHbO,100),'LineWidth',2, 'Color','#A2142F');
    ylim([-20 75])
    hold on
    plot(x, movmedian(yMeanHbR,100),'LineWidth',2, 'Color','#0072BD');
    plot(x, movmedian(yMeanHbT,100),'LineWidth',2, 'Color','#77AC30');
    
    patch([x, fliplr(x)], [yMean + yCI95(1,:) fliplr(yMean + yCI95(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)
    title([TitleList{index} ' - Mean'])
    f.Position = [10 10 1500 500]; %for size of screen before saving
    set(axes,'FontSize',14,'FontWeight','bold','LineWidth',2);
    
    patch([x, fliplr(x)], [yMeanHbO + yCI95HbO(1,:) fliplr(yMeanHbO + yCI95HbO(2,:))], 'r' ,'EdgeColor','none', 'FaceAlpha',0.25)
    patch([x, fliplr(x)], [yMeanHbR + yCI95HbR(1,:) fliplr(yMeanHbR + yCI95HbR(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)
    patch([x, fliplr(x)], [yMeanHbT + yCI95HbT(1,:) fliplr(yMeanHbT + yCI95HbT(2,:))], 'g', 'EdgeColor','none', 'FaceAlpha',0.25)
    
    title([TitleList{index} ' - Mean'])
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/Hemodynamics/' HypoxiaLevel '-HbOmean.png'])
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/Hemodynamics/' HypoxiaLevel '-HbOmean.fig'])
    
    close all

end

print('bla')
