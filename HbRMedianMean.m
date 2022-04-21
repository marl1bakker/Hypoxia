%% HbO/HbR median and mean over brain, makes arrays with all mice and acquisitions
% ManualInput 1 = overwrite any files that are already there
% ManualInput 0 = Dont overwrite files that are there, skip those
% acquisitions 
% Grabs HbR over the whole brain but minus the sinus. 

function HbRMedianMean(Glist, ManualInput)

%bij geen manual input doe niet overwriten
if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

%% HbR
% als je niet wil overschrijven als hij bestaat, en hij bestaat, return
if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/Hemodynamics/HbRmedian.mat', 'file') )
    disp('HbR Calculation already done, exited function')
    return;
end

if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/Hemodynamics/HbRmedian.mat', 'file') )
    disp('HbR Calculation already done, OVERWRITING FILES')
end

mean_HbR_list = zeros(size(Glist, 2), 48000);
median_HbR_list = zeros(size(Glist, 2), 48000);

%calculate median and mean for all mice
for ind = 1:size(Glist,2)
    disp(Glist(ind));
    % Load HbR data
    %     HbR = load([Glist(ind).name filesep 'HbR.mat']);
    %     HbR = HbR.HbR;
    %     HbR = reshape(HbR, 192,192,[]);
    fid = fopen([Glist(ind).name filesep 'HbR.dat']);
    HbR = fread(fid,  inf, '*single');
    HbR = reshape(HbR, 192, 192, []);
    dims = size(HbR);
    disp('HbR loaded')
    
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
    HbR = HbR .* Mask;
    HbR(HbR == 0) = NaN;
    HbR = reshape(HbR, (dims(1)*dims(2)), []);
    
    Mask = Mask&~reshape(any(isnan(HbR),2),192,192);
    % Take Zscores to remove outliers
    zscores_per_frame = zeros(size(HbR),'single');
    zscores_per_frame(Mask(:),:) = zscore(HbR(Mask(:),:), 0, 1);
    zscores_per_frame = abs(zscores_per_frame) <= 3; %this is now a mask
    HbR = HbR .* zscores_per_frame;
    HbR(HbR == 0) = NaN; 
    HbRmean = mean(HbR, 1, 'omitnan');
    HbRmedian = median(HbR, 1, 'omitnan');
    
    if size(HbRmean, 2) < 48000 % zorg dat die ene acquisitie di minder is dan 48000 niet alles verneukt
        HbRmean(size(HbRmean, 2):48000) = NaN;
    else %alles zelfde grootte voor matrix
        HbRmean = HbRmean(1:48000);
    end
    mean_HbR_list(ind, :) = HbRmean;
    
    if size(HbRmedian, 2) < 48000 % zorg dat die ene acquisitie di minder is dan 48000 niet alles verneukt
        HbRmedian(size(HbRmedian, 2):48000) = NaN;
    else %alles zelfde grootte voor matrix
        HbRmedian = HbRmedian(1:48000);
    end
    median_HbR_list(ind, :) = HbRmedian;
end

%Change timing for hypoxia 10 percent for girls
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_10');
    index = strfind(Glist(ind).name, 'TheGirls');
    if ~isempty(idx) && ~isempty(index)
        CorrectedHbRmedian = median_HbR_list(ind, 9600:end); %haal eerste 8 minuten eraf
        CorrectedHbRmedian(:,end+1:48000) = missing;
        median_HbR_list(ind, :) = CorrectedHbRmedian;
        
        CorrectedHbRmean = mean_HbR_list(ind, 9600:end);
        CorrectedHbRmean(:,end+1:48000) = missing;
        mean_HbR_list(ind, :) = CorrectedHbRmean;
    end
end

%Delete last frames 552 hypox 12
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_12'); 
    index = strfind(Glist(ind).name, '552');
    if ~isempty(idx) && ~isempty(index)
        CorrectedHbRmedian = median_HbR_list(ind, 1:42000); %remove last minutes, after error
        CorrectedHbRmedian(:,end+1:48000) = missing;
        median_HbR_list(ind, :) = CorrectedHbRmedian;
        
        CorrectedHbRmean = mean_HbR_list(ind, 1:42000);
        CorrectedHbRmean(:,end+1:48000) = missing;
        mean_HbR_list(ind, :) = CorrectedHbRmean;
    end
end

%Delete Katy after first 8% hypoxia because went back too late
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_8_1'); 
    index = strfind(Glist(ind).name, 'Katy');
    if ~isempty(idx) && ~isempty(index)
        CorrectedHbRmedian = median_HbR_list(ind, 1:24000); %remove last minutes, after error
        CorrectedHbRmedian(:,end+1:48000) = missing;
        median_HbR_list(ind, :) = CorrectedHbRmedian;
        
        CorrectedHbRmean = mean_HbR_list(ind, 1:24000);
        CorrectedHbRmean(:,end+1:48000) = missing;
        mean_HbR_list(ind, :) = CorrectedHbRmean;
    end
end


save('/media/mbakker/data1/Hypoxia/Hemodynamics/HbRmean.mat', 'mean_HbR_list')
save('/media/mbakker/data1/Hypoxia/Hemodynamics/HbRmedian.mat', 'median_HbR_list')