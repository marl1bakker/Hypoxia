% load('/media/mbakker/data1/Hypoxia/Glist.mat')

%Method is 'std' or 'mean'
function GCaMPFluctuations(HypoxiaLevels, Glist, ManualInput, GSR, Method)

if ~exist('Method', 'var')
    Method = 'std';
end

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if ~exist('GSR', 'var')
    GSR = 1;
end

for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    FluctuationsStd= zeros(8, 48000, 7); %hardcoded on mice, time and nr of seeds
    IndexMouse = 0;
    
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        
        if ~isempty(idx)
            
            if GSR == 1
                load([Glist(ind).name filesep 'Timecourses.mat']);
            else
                load([Glist(ind).name filesep 'Timecourses_NoGSR.mat']);
            end
            
            %% timing is not always good, got from CombiCorrMatrices code
            % if it's the girls 10%, correct for hypoxia timing, if its 552
            % 12%, correct for problem in acquisition
            indhypox10 = strfind(Glist(ind).name, 'Hypox_10');
            indthegirls = strfind(Glist(ind).name, 'TheGirls');
            if ~isempty(indhypox10) && ~isempty(indthegirls)
                Timecourses = Timecourses(:,9600:end); %haal eerste 8 minuten eraf
                Timecourses(:,end+1:48000) = missing; %plak missing values aan het einde
            end
            indhypox12 = strfind(Glist(ind).name, 'Hypox_12'); %552 problem with acquisition, after 42000 has to be cut
            ind552 = strfind(Glist(ind).name, '552');
            if ~isempty(indhypox12) && ~isempty(ind552)
                Timecourses = Timecourses(:, 1:42000);
                Timecourses(:,end+1:48000) = missing;
            end
            
            indhypox82 = strfind(Glist(ind).name, 'Hypox_8_2'); 
            indTom = strfind(Glist(ind).name, 'Tom');
            if ~isempty(indhypox82) && ~isempty(indTom)
                Timecourses(:,end+1:48000) = missing;
            end
            
            
            
            %% continue, get moving std per seed
            if matches(Method, 'std')
                StdAct = movstd(Timecourses, 10, 0, 2, 'omitnan'); %0 is for w, default
            elseif matches(Method, 'mean')
                StdAct = movmean(Timecourses, 10, 2, 'omitnan');
            end %if chosen mean method, the names are a bit weird since they keep referring to std, but the method is valid
            
            if size(StdAct, 2) >= 48000
                StdAct = StdAct(:, 1:48000);
            else
                StdAct(:,end+1:48000) = missing;
            end
            
            IndexMouse = IndexMouse + 1;
            FluctuationsStd(:,:,IndexMouse) = StdAct;
            %seeds * time * mouse
            
        end
    end
    
    %% plot
    x = linspace(0,40,48000);
    f = figure('InvertHardcopy','off','Color',[1 1 1]);
    plotcolours = [[0, 0.4470, 0.7410], [0.929, 0.694, 0.125], [0.635, 0.078, 0.184], [0.494, 0.184, 0.556], ...
        [0.3010 0.7450 0.9330],[1, 0.9, 0.1] ,[0.9, 0.1, 0.1] , [0.75, 0, 0.75]];
    colind1 = 1;
    colind2 = 3;
    
    for ind = 1:size(FluctuationsStd,1) % per seed
        seed = FluctuationsStd(ind,:,:);
        seed = reshape(seed,size(FluctuationsStd, 2), size(FluctuationsStd,3));
        
        yMean = mean(seed, 2, 'omitnan');
        yMean = movmedian(yMean, 1000, 1);
%         ySEM = std(seed, 0, 2, 'omitnan')/sqrt(8);
%         ySEM = movmedian(ySEM, 1000, 1);

%         CI95 = tinv([0.025 0.975], 8-1);
%         yCI95 = bsxfun(@times,ySEM', CI95(:));
        
        plot(x, yMean','LineWidth',2, 'Color', plotcolours(colind1:colind2));
        hold on
%         patch([x, fliplr(x)], [yMean' + yCI95(1,:) fliplr(yMean' + yCI95(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)
        
        colind1 = colind1 +3;
        colind2 = colind2 +3;
    end
    
    axes1 = gca;
    hold(axes1,'on');
    set(axes1,'FontSize',20,'FontWeight','bold','LineWidth',2);
    if matches(Method, 'std')
        ylim([0.0 0.02])
    elseif matches(Method, 'mean')
        ylim([0.995 1.005])
    end
    f.Position = [10 10 1500 500]; %for size of screen before saving
    title([Method ' GCaMP activity ' HypoxiaLevel], 'Interpreter', 'none')
    yl = ylim;
    line([10 10], yl);
    line([20 20], yl);
    
    %legend
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    legend(labels)
    
    %Save
    if GSR == 1 && matches(Method, 'std')
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_std.eps'], 'epsc');
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_std.tiff'], 'tiff');
    elseif GSR == 0 && matches(Method, 'std')
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_std_NoGSR.eps'], 'epsc');
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_std_NoGSR.tiff'], 'tiff');
    elseif GSR == 1 && matches(Method, 'mean')
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_mean.eps'], 'epsc');
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_mean.tiff'], 'tiff');
    elseif GSR == 0 && matches(Method, 'mean')
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_mean_NoGSR.eps'], 'epsc');
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_mean_NoGSR.tiff'], 'tiff');
    end
    
    close all
    
end
end


































%% Version for whole brain
% Not well done yet! check the movstd thing

% function GCaMPFluctuations(HypoxiaLevels, Glist, ManualInput, GSR)
%
%
% if ~exist('ManualInput', 'var')
%     ManualInput = 0;
% end
%
% if ~exist('GSR', 'var')
%     GSR = 1;
% end
%
% for index = 1:size(HypoxiaLevels, 2)
%     HypoxiaLevel = HypoxiaLevels{index};
%     FluctuationsStd= [];
%     FluctuationsMean = [];
%
%     for ind = 1:size(Glist,2)
%         idx = strfind(Glist(ind).name, HypoxiaLevel);
%
%         if ~isempty(idx)
%
%             fid = fopen([Glist(ind).name filesep 'fChanCor.dat']);
%             dat = fread(fid, inf, '*single');
%             dat = reshape(dat, 192,192, []);
%
%             load([Glist(ind).name filesep 'MaskC.mat']); %get specific mask per acquisition to make sure you dont get seeds that are outliers or on window artefacts
%             Mask = Mask;
%             dat = dat.*Mask;
%             dat(dat == 0) = NaN;
%             clear Mask idx
%             dat = reshape(dat, 192*192, []);
%
% %             StdAct1 = std(dat,1,'omitnan');
%             StdAct = movstd(dat, 10, 0, 2, 'omitnan');
%             MeanAct = mean(dat,1,'omitnan');
%
%             if size(StdAct, 2) >= 48000
%                 StdAct = StdAct(1:48000);
%                 MeanAct = MeanAct(1:48000);
%             else
%                 StdAct(:,end+1:48000) = missing;
%                 MeanAct(:,end+1:48000)= missing;
%             end
%             FluctuationsStd = [FluctuationsStd; StdAct];
%             FluctuationsMean = [FluctuationsMean; MeanAct];
%
%         end
%     end
%
%     x = linspace(0,40,48000);
%     yMean = mean(FluctuationsStd, 1, 'omitnan');
%     yMean = movmedian(yMean, 500);
%     ySEM = std(FluctuationsStd, 1, 'omitnan')/sqrt(8);
%     ySEM = movmedian(ySEM, 500);
%     CI95 = tinv([0.025 0.975], 8-1);
%     yCI95 = bsxfun(@times,ySEM, CI95(:));
%
%     f = figure('InvertHardcopy','off','Color',[1 1 1]);
%     axes1 = axes;
%     hold(axes1,'on');
%     set(axes1,'FontSize',20,'FontWeight','bold','LineWidth',2);
%     plot(x, yMean,'LineWidth',2);
% %     ylim([50 85])
%     hold on
%     patch([x, fliplr(x)], [yMean + yCI95(1,:) fliplr(yMean + yCI95(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)
%     f.Position = [10 10 1500 500]; %for size of screen before saving
%     title('Standard Deviation GCaMP activity')
%     %Save
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_std.eps'], 'epsc')
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_std.tiff'], 'tiff')
%
%     close all
%
% %     %mean
% %     x = linspace(0,40,48000);
% %     yMean = mean(FluctuationsMean, 1, 'omitnan');
% %     yMean = movmedian(yMean, 500);
% %     ySEM = std(FluctuationsMean, 1, 'omitnan')/sqrt(8);
% %     ySEM = movmedian(ySEM, 500);
% %     CI95 = tinv([0.025 0.975], 8-1);
% %     yCI95 = bsxfun(@times,ySEM, CI95(:));
% %
% %     f = figure('InvertHardcopy','off','Color',[1 1 1]);
% %     axes1 = axes;
% %     hold(axes1,'on');
% %     set(axes1,'FontSize',20,'FontWeight','bold','LineWidth',2);
% %     plot(x, yMean,'LineWidth',2);
% % %     ylim([50 85])
% %     hold on
% %     patch([x, fliplr(x)], [yMean + yCI95(1,:) fliplr(yMean + yCI95(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)
% %     f.Position = [10 10 1500 500]; %for size of screen before saving
% %     title('Mean GCaMP activity')
% %     %Save
% %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_mean.eps'], 'epsc')
% %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_mean.tiff'], 'tiff')
% %
%     close all
% end
% end
