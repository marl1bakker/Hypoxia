%% spO2 linegraph

function spO2linegraph(HypoxiaLevels, Glist, TitleList, ManualInput)
if ~exist('ManualInput', 'var')
    ManualInput = 0;
end
if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/spO2/Hypox_8_1-mean.fig', 'file') )
    disp('spO2 plotting already done, exited function')
    return;
end
if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/spO2/Hypox_8_1-mean.fig', 'file') )
    disp('spO2 plotting already done, OVERWRITING FILES')
end


load('/media/mbakker/data1/Hypoxia/spO2/spO2mean.mat')
load('/media/mbakker/data1/Hypoxia/spO2/spO2median.mat')

if ~exist('TitleList', 'var')
    TitleList = HypoxiaLevels;
end

for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    
    %% median
    spO2Hlevel = [];
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        if ~isempty(idx)
            spO2Hlevel = [spO2Hlevel; median_spO2_list(ind, :)];
        end
    end
    
    x = linspace(0,40,48000); %x axis in min
    yMean = mean(spO2Hlevel, 1, 'omitnan');
    yMean = movmedian(yMean, 200);
    ySEM = std(spO2Hlevel, 1, 'omitnan')/sqrt(8);
    ySEM = movmedian(ySEM, 200);
    CI95 = tinv([0.025 0.975], 8-1);
    yCI95 = bsxfun(@times,ySEM, CI95(:));
    
    %transfer to percentage
    yMean = yMean * 100;
    yCI95 = yCI95 * 100;
    
    %NEW
    f = figure('InvertHardcopy','off','Color',[1 1 1]);
    axes1 = axes;
    hold(axes1,'on');
    set(axes1,'FontSize',14,'FontWeight','bold','LineWidth',2);
    plot(x, yMean,'LineWidth',2);
    ylim([50 85])
    hold on
    patch([x, fliplr(x)], [yMean + yCI95(1,:) fliplr(yMean + yCI95(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)
    title([TitleList{index} ' - Median'])
    f.Position = [10 10 1500 500]; %for size of screen before saving
    
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/spO2/' HypoxiaLevel '-linegraph-median.png'])
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/spO2/' HypoxiaLevel '-linegraph-median.png'])
    
    close all
    
    %mean
    spO2Hlevel = [];
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        if ~isempty(idx)
            spO2Hlevel = [spO2Hlevel; mean_spO2_list(ind, :)];
        end
    end
    
    x = linspace(0,40,48000);
    yMean = mean(spO2Hlevel, 1, 'omitnan');
    yMean = movmedian(yMean, 200);
    ySEM = std(spO2Hlevel, 1, 'omitnan')/sqrt(8);
    ySEM = movmedian(ySEM, 200);
    CI95 = tinv([0.025 0.975], 8-1);
    yCI95 = bsxfun(@times,ySEM, CI95(:));
    
    %transfer to percentage
    yMean = yMean * 100;
    yCI95 = yCI95 * 100;
    
    %NEW
    f = figure('InvertHardcopy','off','Color',[1 1 1]);
    axes1 = axes;
    hold(axes1,'on');
    set(axes1,'FontSize',14,'FontWeight','bold','LineWidth',2);
    plot(x, yMean,'LineWidth',2);
    ylim([50 85])
    hold on
    patch([x, fliplr(x)], [yMean + yCI95(1,:) fliplr(yMean + yCI95(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)
    title([TitleList{index} ' - Mean'])
    f.Position = [10 10 1500 500]; %for size of screen before saving
    
    %Save
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/spO2/' HypoxiaLevel '-linegraph-mean.png'])
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/spO2/' HypoxiaLevel '-linegraph-mean.fig'])
    
    close all
    
end
