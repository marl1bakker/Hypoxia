%% spO2 plots
%whole brain spo2
load('/media/mbakker/data1/Hypoxia/Glist.mat');

% Glist = Glist(1:32); %only the boys
mean_spO2_list = zeros(size(Glist, 2), 48000);

for ind = 1:size(Glist,2)
    %% Load spO2 data
    
    fid = fopen([Glist(ind).name filesep 'spO2.dat']);
    spO2 = fread(fid,  inf, '*single');
    spO2 = reshape(spO2, 192,192,[]);
    
    dims = size(spO2);
    %     spO2 = reshape(spO2, (dims(1)*dims(2)), dims(3));
    
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
    clear indA
    
    idx = arrayfun(@(x) endsWith(ROI_info(x).Name, '_L'), 1:size(ROI_info,2));
    RH_Mask = imfill(bwmorph(ismember(Atlas,find(~idx)) ,'close',inf),'holes');
    LH_Mask = imfill(bwmorph(ismember(Atlas,find(idx)),'close',inf),'holes');
    se = strel('disk', 7);
    RH_Mask = imdilate(RH_Mask, se); %breid uit naar neighbourhood
    LH_Mask = imdilate(LH_Mask, se);

    SinusMask = RH_Mask & LH_Mask;
    clear idx RH_Mask LH_Mask se
    
%     imerode()
    
    %ugly way but whatever
    spO2 = spO2 .* ~SinusMask;
    spO2(spO2 == 0) = NaN;
    spO2 = reshape(spO2, (dims(1)*dims(2)), []);
    
    %%
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

% % Maak lijsten met acquisitions en muizen, volgorde van Glist
% for ind = 1:size(Glist,2)
%     idx = strfind(Glist(ind).name, filesep); %zoek alle plekken van fileseps in naam
%     NameAcq = [Glist(ind).name(idx(end)+1:end)]; %pak naam tot laatste filesep, plak normoxia 1 achter
%     Acquisition(ind).name = NameAcq;
% end
% 
% for ind = 1:size(Glist,2)
%     idx = strfind(Glist(ind).name, filesep); %zoek alle plekken van fileseps in naam
%     NameMouse = [Glist(ind).name(idx(end-1)+1:idx(end)-1)]; %pak naam tot laatste filesep, plak normoxia 1 achter
%     Mice(ind).name = NameMouse;
% end
% 
% clear idx ind NameAcq NameMouse

% spO2meanHypoxia = mean(mean_spO2_list(:,(12000+2400):(24000-2400)), 2, 'omitnan');
% ALLEEN HYPOXIA PERIODE
spO2Hypoxia = (mean_spO2_list(:,(12000+2400):(24000)));
% GEHELE TIJD MEAN

% GEHELE TIJD MEDIAN
spO2Hypoxia = median_spO2_list;

%sort
spO2Table = [struct2table(Glist), array2table(spO2Hypoxia)];
spO2Table = sortrows(spO2Table, 1);
% spO2Table = spO2Table(:,2);
spO2Array = spO2Table(:,2:end);
spO2Array = table2array(spO2Array);

spO2Array = reshape(spO2Array, 8, 8, []);
%Nu acquisition H10 H12 H81 H82 N1 N2 N2 N4 bij 
% muis, 087 227 552 Chiploos jane katy nick tom

spO2Table = [struct2table(Glist), array2table(spO2Hypoxia)];
spO2Table = sortrows(spO2Table, 1);
spO2Array = spO2Table(:,2:end);
spO2Array = table2array(spO2Array);

% Divide into groups for hypoxia levels
spO_H10 = [];
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_10'); 
    if ~isempty(idx)
        spO_H10 = [spO_H10; spO2Array(ind, :)];
    end
end

spO_H8_1 = [];
for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, 'Hypox_8_1'); 
    if ~isempty(idx)
        spO_H8_1 = [spO_H8_1; spO2Array(ind, :)];
    end
end

% HypoxiaLevels = {'Hypox_12','Hypox_10', 'Hypox_8_1', 'Hypox_8_2',...
%     'Normoxia_1', 'Normoxia_2', 'Normoxia_3', 'Normoxia_4'};
% for index = 1:HypoxiaLevels
%     
%     spO_HLevel = [];
%     for ind = 1:size(Glist,2)
%         idx = strfind(Glist(ind).name, HypoxiaLevel(index));
%         if ~isempty(idx)
%             spO_HLevel = [spO_HLevel; spO2Array(ind, :)];
%         end
%     end
%     strcat('spO_', HypoxiaLevels(index)) = spO_HLevel;
%     
% end

%% shit
Mice = [{}]

a = 8; %number of mice

boxplots = {spO2Table(1:a), spO2Table(a+1:2*a), spO2Table(2*a+1:3*a), spO2Table(3*a+1:4*a),...
    spO2Table(4*a+1:5*a), spO2Table(5*a+1:6*a), spO2Table(6*a+1:7*a), spO2Table(7*a+1:8*a)};
boxplotGroup(boxplots)

for ind = 1:size(spO2Array, 1)
    boxplots{ind} = spO2Array(ind,:);
end
Hypoxia10 = boxplots(1:8);
Hypoxia12 = boxplots(9:16);

boxplots = {spO2Array(1:a,1:100), spO2Array(a+1:2*a,1:100), spO2Array(2*a+1:3*a,1:100)};
boxplotGroup(spO2Array)
boxplotGroup(Hypoxia10)








