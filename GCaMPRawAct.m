% load('/media/mbakker/data1/Hypoxia/Glist.mat')


function GCaMPRawAct(HypoxiaLevels, Glist, ManualInput, GSR)


if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if ~exist('GSR', 'var')
    GSR = 1;
end

for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    Fluctuations= zeros(8, 48000, 8); %hardcoded on mice, time and nr of seeds
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
            
%             Act = movstd(Timecourses, 10, 0, 2, 'omitnan');
            Act = Timecourses;
            
            if size(Act, 2) >= 48000
                Act = Act(:, 1:48000);
            else
                Act(:,end+1:48000) = missing;
            end
            
            IndexMouse = IndexMouse + 1;
            Fluctuations(:,:,IndexMouse) = Act;
            %seeds * time * mouse
            
        end
    end
    
    %% plot
    x = linspace(0,40,48000);
    f = figure('InvertHardcopy','off','Color',[1 1 1]);
    
    for ind = 1:size(Fluctuations,1)
        seed = Fluctuations(ind,:,:);
        seed = reshape(seed,48000, 8);
        
        yMean = mean(seed, 2, 'omitnan');
        yMean = movmedian(yMean, 1000, 1);
        ySEM = std(seed, 0, 2, 'omitnan')/sqrt(8);
        ySEM = movmedian(ySEM, 1000, 1);

        CI95 = tinv([0.025 0.975], 8-1);
        yCI95 = bsxfun(@times,ySEM', CI95(:));
        
        plot(x, yMean','LineWidth',2);
        hold on
%         patch([x, fliplr(x)], [yMean' + yCI95(1,:) fliplr(yMean' + yCI95(2,:))], 'b', 'EdgeColor','none', 'FaceAlpha',0.25)
        
    end
    
    axes1 = gca;
    hold(axes1,'on');
    set(axes1,'FontSize',20,'FontWeight','bold','LineWidth',2);
    ylim([0.999 1.001])
    f.Position = [10 10 1500 500]; %for size of screen before saving
    title(['GCaMP activity ' HypoxiaLevel], 'Interpreter', 'none')
    yl = ylim;
    line([10 10], yl);
    line([20 20], yl);
    
    %legend
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    legend(labels)
    
    %Save
    if GSR == 1
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_raw.eps'], 'epsc');
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_raw.tiff'], 'tiff');
    else
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_std_NoGSR.eps'], 'epsc');
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/Fluctuations/' HypoxiaLevel '_GCaMP_std_NoGSR.tiff'], 'tiff');
    end
    
    close all
    
end
end
