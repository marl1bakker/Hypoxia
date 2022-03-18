%% spatial distribution of spo2 changes
% Get an image of the brain that shows the increase/decrease in spO2 during
% hypoxia minus before. This is all mice combined


function spO2SpatialDistribution(HypoxiaLevels, Glist, TitleList, ManualInput)
if ~exist('ManualInput', 'var')
    ManualInput = 0;
end
if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/spO2/Hypox_8_1spatialdist-median.fig', 'file') )
    disp('spO2 spatial distribution already done, exited function')
    return;
end
if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/spO2/Hypox_8_1spatialdist-median.fig', 'file') )
    disp('spO2 spatial distribution already done, OVERWRITING FILES')
end

if ~exist('TitleList', 'var')
    TitleList = HypoxiaLevels;
end



Differences = [];


for ind = 1:size(Glist,2)
    % make a spatial distribution per animal per acquisition
    %First load data
    disp(Glist(ind));
    fid = fopen([Glist(ind).name filesep 'spO2.dat']);
    spO2 = fread(fid,  inf, '*single');
    spO2 = reshape(spO2, 192*192,[]);
    
    if ( contains(Glist(ind).name, 'Hypox_10') ) && ( contains(Glist(ind).name, 'TheGirls') )
        %grab minute 2.5 to minute 7.5 for before hypoxia and minute 12.5 to
        %17.5 for hypoxia. Take the mean spO2 values over that timeframe. Then
        %calculate the difference and plot it. Save in the folder of the
        %acquisition.
        BeforeHypox = mean(spO2(:,3001:9000),2);
        DuringHypox = mean(spO2(:,15001:21000),2);
        Difference = DuringHypox - BeforeHypox;
        Difference = reshape(Difference, 192,192,[]);
        imagesc(Difference, [-0.25 0.25])
        axis off
        colorbar
        title(Glist(ind).name)
        saveas(gcf, [Glist(ind).name filesep 'SpatialDistribution_SpO2.png']);
        
        %In order to combine mice of the same hypox value, also save the
        %difference in the array, together with the name so you can match
        %hypoxia levels
        Difference = reshape(Difference, 1,192*192);
        Differences = [Differences; Difference];
        %Like this you will have the maps of all acquisitions below each other.
    else
        
        %grab minute 2.5 to minute 7.5 for before hypoxia and minute 12.5 to
        %17.5 for hypoxia. Take the mean spO2 values over that timeframe. Then
        %calculate the difference and plot it. Save in the folder of the
        %acquisition.
        BeforeHypox = mean(spO2(:,3001:9000),2);
        DuringHypox = mean(spO2(:,15001:21000),2);
        Difference = DuringHypox - BeforeHypox;
        Difference = reshape(Difference, 192,192,[]);
        imagesc(Difference, [-0.25 0.25])
        axis off
        colorbar
        title(Glist(ind).name)
        saveas(gcf, [Glist(ind).name filesep 'SpatialDistribution_SpO2.png']);
        
        %In order to combine mice of the same hypox value, also save the
        %difference in the array, together with the name so you can match
        %hypoxia levels
        Difference = reshape(Difference, 1,192*192);
        Differences = [Differences; Difference];
        %Like this you will have the maps of all acquisitions below each other.
    end
    
end


save('/media/mbakker/data1/Hypoxia/spO2/Differences.mat', 'Differences');


%% Combine all acquisitions of the same level
for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    Hlevel = [];
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        if ~isempty(idx)
            Hlevel = [Hlevel; Differences(ind, :)];
        end
    end
    AvHlevelmean = mean(Hlevel, 1, 'omitnan');
    AvHlevelmean = reshape(AvHlevelmean, 192,192);
    imagesc(AvHlevelmean)
    colorbar
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/spO2/' HypoxiaLevel 'spatialdist-mean.png']);    
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/spO2/' HypoxiaLevel 'spatialdist-mean.fig']);    
    close all
    
    AvHlevelmedian = median(Hlevel, 1, 'omitnan');
    AvHlevelmedian = reshape(AvHlevelmedian, 192,192);
    imagesc(AvHlevelmedian)
    colorbar
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/spO2/' HypoxiaLevel 'spatialdist-median.png']);    
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/spO2/' HypoxiaLevel 'spatialdist-median.fig']);    
    close all
end


end

