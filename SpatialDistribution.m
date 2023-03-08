%% spatial distribution of HbO changes
% Get an image of the brain that shows the increase/decrease in HbO during
% hypoxia minus before. This is all mice combined

% DataType is 'HbO', 'HbR' or 'spO2'

% 16-7-2022 adaptation: add scale, make axis equal

function SpatialDistribution(HypoxiaLevels, Glist, DataType, ManualInput, GSR)
if ~exist('ManualInput', 'var')
    ManualInput = 0;
end
if( ManualInput == 0 ) && ( exist(['/media/mbakker/data1/Hypoxia/SpatialDist/' DataType '/Hypox_8_1' DataType 'spatialdist-median.fig'], 'file') )
    disp([DataType ' spatial distribution already done, exited function'])
    return;
end
if( ManualInput == 1 ) && ( exist(['/media/mbakker/data1/Hypoxia/SpatialDist/' DataType '/Hypox_8_1spatialdist-median.fig'], 'file') )
    disp([DataType ' spatial distribution already done, OVERWRITING FILES'])
end

if ~exist('GSR', 'var')
    GSR = 0;
end

Differences = [];

for ind = 1:size(Glist,2)
    %% make a spatial distribution per animal per acquisition
    if matches(DataType, 'HbT')
        disp(Glist(ind));
        fid = fopen([Glist(ind).name filesep 'HbO.dat']);
        HbO = fread(fid,  inf, '*single');
        HbO = reshape(HbO, 192, 192, []);
        fid = fopen([Glist(ind).name filesep 'HbR.dat']);
        HbR = fread(fid,  inf, '*single');
        HbR = reshape(HbR, 192, 192, []);
        
        data = HbO + HbR;
    else
        %First load data
        disp(Glist(ind));
        fid = fopen([Glist(ind).name filesep DataType '.dat']);
        data = fread(fid,  inf, '*single');
        data = reshape(data, 192, 192, []);
    end
    
    idx = strfind(Glist(ind).name, filesep); %zoek alle plekken van fileseps in naam
    Mask = load([Glist(ind).name(1:idx(end)) 'Mask.mat']); %get general mask of mouse
    Mask = Mask.Mask;
    data = data.*Mask;
    data(data == 0) = NaN;
    
%     data = reshape(data, 192*192,[]);
    
    %% GSR
dims = size(data);
data = reshape(data,[], dims(3));

if GSR == 1
    mS = mean(data,1, 'omitnan');
    X = [ones(size(mS)); mS];
    B = X'\data';
    A = (X'*B)';
    data = data - A; % - because its hbo hbr,
    clear h Mask mS X B A;
end
    
    %%
    %grab minute 2.5 to minute 7.5 for before hypoxia and minute 12.5 to
    %17.5 for hypoxia. Take the mean HbO values over that timeframe. Then
    %calculate the difference and plot it. Save in the folder of the
    %acquisition.
    BeforeHypox = mean(data(:,3001:9000),2);
    DuringHypox = mean(data(:,15001:21000),2);
    Difference = DuringHypox - BeforeHypox;
    Difference = reshape(Difference, 192,192,[]);
    %         imagesc(Difference, [-0.25 0.25])
    if matches(DataType, 'spO2')
        imagesc(Difference,'AlphaData', ~isnan(Difference), [-0.25 0.25])
    else
        imagesc(Difference,'AlphaData', ~isnan(Difference), [-100 100])
    end
    axis image
    hold on
    line([5 20.7], [5 5]);
    line([5 5], [5 20.7]); %for scale, it's 157 pix for 10 mm
    colorbar
    title(Glist(ind).name)
    
    if GSR == 0
        saveas(gcf, [Glist(ind).name filesep 'SpatialDistribution_' DataType '_noGSR.png']);
    else
        saveas(gcf, [Glist(ind).name filesep 'SpatialDistribution_' DataType '_GSR.png']);
    end
    
    sepsloc = strfind(Glist(ind).name, filesep);
    HypoxiaLevel = Glist(ind).name(sepsloc(end)+1:end);
    
    if contains(Glist(ind).name, '227') && GSR == 0
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/SpatialDist' filesep DataType filesep HypoxiaLevel '_227_noGSR.png']);
    elseif contains(Glist(ind).name, '227') && GSR == 1
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/SpatialDist' filesep DataType filesep HypoxiaLevel '_227_GSR.png']);
    end
    
    %In order to combine mice of the same hypox value, also save the
    %difference in the array, together with the name so you can match
    %hypoxia levels
    Difference = reshape(Difference, 1,192*192);
    Differences = [Differences; Difference];
    %Like this you will have the maps of all acquisitions below each other.
    
    close all
end


if GSR == 0
    save(['/media/mbakker/data1/Hypoxia/SpatialDist/' DataType '/Differences_noGSR.mat'], 'Differences');
else
    save(['/media/mbakker/data1/Hypoxia/SpatialDist/' DataType '/Differences_GSR.mat'], 'Differences');
end

%% Combine all acquisitions of the same level
% for index = 1:size(HypoxiaLevels, 2)
%     HypoxiaLevel = HypoxiaLevels{index};
%     Hlevel = [];
%     for ind = 1:size(Glist,2)
%         idx = strfind(Glist(ind).name, HypoxiaLevel);
%         if ~isempty(idx)
%             Hlevel = [Hlevel; Differences(ind, :)];
%         end
%     end
%     AvHlevelmean = mean(Hlevel, 1, 'omitnan');
%     AvHlevelmean = reshape(AvHlevelmean, 192,192);
%     
%     if matches(DataType, 'spO2')
%         imagesc(AvHlevelmean,'AlphaData', ~isnan(AvHlevelmean), [-0.25 0.25])
%     else
%         imagesc(AvHlevelmean,'AlphaData', ~isnan(AvHlevelmean), [-100 100])
%     end
%     axis equal
%     axis off
%     colorbar
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/SpatialDist/' DataType filesep HypoxiaLevel DataType 'spatialdist-mean.tiff']);
% %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/SpatialDist/' DataType filesep HypoxiaLevel DataType 'spatialdist-mean.fig']);
%     close all

%     AvHlevelmedian = median(Hlevel, 1, 'omitnan');
%     AvHlevelmedian = reshape(AvHlevelmedian, 192,192);
% %     imagesc(AvHlevelmedian)
%    imagesc(AvHlevelmedian,'AlphaData', ~isnan(AvHlevelmedian), [-0.25 0.25])
%     axis off
%     colorbar
% %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/SpatialDist/' DataType filesep HypoxiaLevel DataType 'spatialdist-median.tiff']);
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/SpatialDist/' DataType filesep HypoxiaLevel DataType 'spatialdist-median.fig']);
%     close all
% end


end

