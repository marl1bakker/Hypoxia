%% HbO/HbR median and mean over brain, makes arrays with all mice and acquisitions
% ManualInput 1 = overwrite any files that are already there
% ManualInput 0 = Dont overwrite files that are there, skip those
% acquisitions 
% Grabs HbO over the whole brain but minus the sinus. 

function HbOMedianMean(Glist, ManualInput)

%bij geen manual input doe niet overwriten
if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

%% HbO
% als je niet wil overschrijven als hij bestaat, en hij bestaat, return
if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/Hemodynamics/HbOmedian.mat', 'file') )
    disp('HbO Calculation already done, exited function')
    return;
end

if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/Hemodynamics/HbOmedian.mat', 'file') )
    disp('HbO Calculation already done, OVERWRITING FILES')
end

mean_HbO_list = zeros(size(Glist, 2), 48000);
median_HbO_list = zeros(size(Glist, 2), 48000);

%calculate median and mean for all mice
for ind = 1:size(Glist,2)
    disp(Glist(ind));
    % Load HbO data
    %     HbO = load([Glist(ind).name filesep 'HbO.mat']);
    %     HbO = HbO.HbO;
    fid = fopen([Glist(ind).name filesep 'HbO.dat']);
    HbO = fread(fid,  inf, '*single');
    HbO = reshape(HbO, 192, 192, []);
    dims = size(HbO);
    disp('HbO loaded')
    
    %% Remove sinusses
    %wil de sinussen niet meenemen, verneukt het signaal. pak die keer dat je
    %de helft moest nemen, breidt ze uit en neem overlappende stuk om weg te
    %halen.
    
    %pak ROI gegevens
    idx = strfind(Glist(ind).name, filesep); %zoek alle plekken van fileseps in naam
    pathFixed = [Glist(ind).name(1:idx(end)) 'Normoxia_1']; %pak naam tot laatste filesep, plak normoxia 1 achter
    load([pathFixed filesep 'ROI_149.mat']);
    clear fid
    
    Atlas = zeros(192);
    for indA = 1:size(ROI_info,2)
        Atlas(ROI_info(indA).Stats.ROI_binary_mask) = indA;
    end
%     OldMask = load([Glist(ind).name filesep 'MaskC.mat']); % om saturatie per acquisition weg te halen
    OldMask = load([Glist(ind).name(1:idx(end)) 'Mask.mat']); %get general mask of mouse
    OldMask = OldMask.Mask;
    Atlas = Atlas .*OldMask; %spo2 file is already within mask, but atlas file isnt yet
    clear indA OldMask idx
    
    idx = arrayfun(@(x) endsWith(ROI_info(x).Name, '_L'), 1:size(ROI_info,2));
    RH_Mask = imfill(bwmorph(ismember(Atlas,find(~idx)) ,'close',inf),'holes');
    LH_Mask = imfill(bwmorph(ismember(Atlas,find(idx)),'close',inf),'holes');
    se = strel('disk', 5);
    
    RH_Mask = imerode(RH_Mask, se);
    LH_Mask = imerode(LH_Mask, se);
    Mask = RH_Mask + LH_Mask;
    clear idx RH_Mask LH_Mask se
    HbO = HbO .* Mask;
    HbO(HbO == 0) = NaN;
    HbO = reshape(HbO, (dims(1)*dims(2)), []);
    
    Mask = Mask&~reshape(any(isnan(HbO),2),192,192);
    %% Take Zscores to remove outliers
    zscores_per_frame = zeros(size(HbO),'single');
    zscores_per_frame(Mask(:),:) = zscore(HbO(Mask(:),:), 0, 1);
    zscores_per_frame = abs(zscores_per_frame) <= 3; %this is now a mask
    HbO = HbO .* zscores_per_frame;
    HbO(HbO == 0) = NaN;    
    
    
    HbOmean = mean(HbO, 1, 'omitnan');
    HbOmedian = median(HbO, 1, 'omitnan');
    
    if size(HbOmean, 2) < 48000 % zorg dat die ene acquisitie di minder is dan 48000 niet alles verneukt
        HbOmean(size(HbOmean, 2):48000) = NaN;
    else %alles zelfde grootte voor matrix
        HbOmean = HbOmean(1:48000);
    end
    mean_HbO_list(ind, :) = HbOmean;
    
    if size(HbOmedian, 2) < 48000 % zorg dat die ene acquisitie di minder is dan 48000 niet alles verneukt
        HbOmedian(size(HbOmedian, 2):48000) = NaN;
    else %alles zelfde grootte voor matrix
        HbOmedian = HbOmedian(1:48000);
    end
    median_HbO_list(ind, :) = HbOmedian;
end

%Change timing for hypoxia 10 percent for girls
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_10');
    index = strfind(Glist(ind).name, 'TheGirls');
    if ~isempty(idx) && ~isempty(index)
        CorrectedHbOmedian = median_HbO_list(ind, 9600:end); %haal eerste 8 minuten eraf
        CorrectedHbOmedian(:,end+1:48000) = missing;
        median_HbO_list(ind, :) = CorrectedHbOmedian;
        
        CorrectedHbOmean = mean_HbO_list(ind, 9600:end);
        CorrectedHbOmean(:,end+1:48000) = missing;
        mean_HbO_list(ind, :) = CorrectedHbOmean;
    end
end

%Delete last frames 552 hypox 12
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_12'); 
    index = strfind(Glist(ind).name, '552');
    if ~isempty(idx) && ~isempty(index)
        CorrectedHbOmedian = median_HbO_list(ind, 1:42000); %remove last minutes, after error
        CorrectedHbOmedian(:,end+1:48000) = missing;
        median_HbO_list(ind, :) = CorrectedHbOmedian;
        
        CorrectedHbOmean = mean_HbO_list(ind, 1:42000);
        CorrectedHbOmean(:,end+1:48000) = missing;
        mean_HbO_list(ind, :) = CorrectedHbOmean;
    end
end

%Delete Katy after first 8% hypoxia because went back too late
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_8_1'); 
    index = strfind(Glist(ind).name, 'Katy');
    if ~isempty(idx) && ~isempty(index)
        CorrectedHbOmedian = median_HbO_list(ind, 1:24000); %remove last minutes, after error
        CorrectedHbOmedian(:,end+1:48000) = missing;
        median_HbO_list(ind, :) = CorrectedHbOmedian;
        
        CorrectedHbOmean = mean_HbO_list(ind, 1:24000);
        CorrectedHbOmean(:,end+1:48000) = missing;
        mean_HbO_list(ind, :) = CorrectedHbOmean;
    end
end


save('/media/mbakker/data1/Hypoxia/Hemodynamics/HbOmean.mat', 'mean_HbO_list')
save('/media/mbakker/data1/Hypoxia/Hemodynamics/HbOmedian.mat', 'median_HbO_list')
