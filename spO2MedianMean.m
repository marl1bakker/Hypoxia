%% spO2 median and mean over brain, makes arrays with all mice and acquisitions
% ManualInput 1 = overwrite any files that are already there
% ManualInput 0 = Dont overwrite files that are there, skip those
% acquisitions 

function spO2MedianMean(Glist,ManualInput)


%bij geen manual input doe niet overwriten
if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

% als je niet wil overschrijven als hij bestaat, en hij bestaat, return
if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/spO2/spO2median.mat', 'file') )  
    disp('spO2 Median/Mean Calculation already done, exited function')
    return;
end

if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/spO2/spO2median.mat', 'file') )  
    disp('spO2 Median/Mean Calculation already done, OVERWRITING FILES')
end

% load('/media/mbakker/data1/Hypoxia/Glist.mat');

mean_spO2_list = zeros(size(Glist, 2), 48000);
median_spO2_list = zeros(size(Glist, 2), 48000);

%calculate median and mean for all mice
for ind = 1:size(Glist,2) 
    disp(Glist(ind));
    % Load spO2 data
    fid = fopen([Glist(ind).name filesep 'spO2.dat']);
    spO2 = fread(fid,  inf, '*single');
    spO2 = reshape(spO2, 192,192,[]);
    dims = size(spO2);
    
    %% Remove sinusses
    %wil de sinussen niet meenemen, verneukt het signaal. pak die keer dat je
    %de helft moest nemen, breidt ze uit en neem overlappende stuk om weg te
    %halen.
    
    %pak ROI gegevens
    idx = strfind(Glist(ind).name, filesep); %zoek alle plekken van fileseps in naam
    pathFixed = [Glist(ind).name(1:idx(end)) 'Normoxia_1']; %pak naam tot laatste filesep, plak normoxia 1 achter
    load([pathFixed filesep 'ROI_149.mat']);
    clear idx fid
    
    Atlas = zeros(192);
    for indA = 1:size(ROI_info,2)
        Atlas(ROI_info(indA).Stats.ROI_binary_mask) = indA;
    end
    OldMask = load([Glist(ind).name filesep 'MaskC.mat']); % om saturatie per acquisition weg te halen
    OldMask = OldMask.Mask;
    Atlas = Atlas .*OldMask; %spo2 file is already within mask, but atlas file isnt yet
    clear indA OldMask
    
    idx = arrayfun(@(x) endsWith(ROI_info(x).Name, '_L'), 1:size(ROI_info,2));
    RH_Mask = imfill(bwmorph(ismember(Atlas,find(~idx)) ,'close',inf),'holes');
    LH_Mask = imfill(bwmorph(ismember(Atlas,find(idx)),'close',inf),'holes');
    se = strel('disk', 5);
    
    RH_Mask = imerode(RH_Mask, se);
    LH_Mask = imerode(LH_Mask, se);
    Mask = RH_Mask + LH_Mask;
    clear idx RH_Mask LH_Mask se
    spO2 = spO2 .* Mask;
    spO2(spO2 == 0) = NaN;
    spO2 = reshape(spO2, (dims(1)*dims(2)), []);
    Mask = Mask&~reshape(any(isnan(spO2),2),192,192);
    % Take Zscores to remove outliers
    zscores_per_frame = zeros(size(spO2),'single');
    zscores_per_frame(Mask(:),:) = zscore(spO2(Mask(:),:), 0, 1);
    zscores_per_frame = abs(zscores_per_frame) <= 3; %this is now a mask
    spO2 = spO2 .* zscores_per_frame;
    spO2(spO2 == 0) = NaN;    
    
    spO2mean = mean(spO2, 1, 'omitnan');
    spO2median = median(spO2, 1, 'omitnan');
    
    if size(spO2mean, 2) < 48000 % zorg dat die ene acquisitie di minder is dan 48000 niet alles verneukt
        spO2mean(size(spO2mean, 2):48000) = NaN;
    else %alles zelfde grootte voor matrix
        spO2mean = spO2mean(1:48000);
    end
    mean_spO2_list(ind, :) = spO2mean;
    
    if size(spO2median, 2) < 48000 % zorg dat die ene acquisitie di minder is dan 48000 niet alles verneukt
        spO2median(size(spO2median, 2):48000) = NaN;
    else %alles zelfde grootte voor matrix
        spO2median = spO2median(1:48000);
    end
    median_spO2_list(ind, :) = spO2median;
end

%Change timing for hypoxia 10 percen for girls
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_10'); 
    index = strfind(Glist(ind).name, 'TheGirls');
    if ~isempty(idx) && ~isempty(index)
        CorrectedspO2median = median_spO2_list(ind, 9600:end); %haal eerste 8 minuten eraf
        CorrectedspO2median(:,end+1:48000) = missing;
        median_spO2_list(ind, :) = CorrectedspO2median;
        
        CorrectedspO2mean = mean_spO2_list(ind, 9600:end);
        CorrectedspO2mean(:,end+1:48000) = missing;
        mean_spO2_list(ind, :) = CorrectedspO2mean;
    end
end

%Delete last frames 552 hypox 12
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_12'); 
    index = strfind(Glist(ind).name, '552');
    if ~isempty(idx) && ~isempty(index)
        CorrectedspO2median = median_spO2_list(ind, 1:42000); %remove last minutes, after error
        CorrectedspO2median(:,end+1:48000) = missing;
        median_spO2_list(ind, :) = CorrectedspO2median;
        
        CorrectedspO2mean = mean_spO2_list(ind, 1:42000);
        CorrectedspO2mean(:,end+1:48000) = missing;
        mean_spO2_list(ind, :) = CorrectedspO2mean;
    end
end

save('/media/mbakker/data1/Hypoxia/spO2/spO2mean.mat', 'mean_spO2_list')
save('/media/mbakker/data1/Hypoxia/spO2/spO2median.mat', 'median_spO2_list')

end
