%% Klad 8 
%% In this script:
% get file
% do hemo correction
% do normalisation
% do gsr
% (do gaussian filter)
% define roi
% plot roi over brain
% do correlation matrixes
% see timecourses of BC

%--------------------------------------------------------------------------
%% Step A. Get to right folder.

% mouse = '169GC_80Hz_7_ID_20210510/CorrectedMissingFrames';
% mouse = '203GC_7o2_80Hz_7ms_ID_20210527/203GC_7o2_80Hz_7ms_ID_20210527';
% mouse = '203GC_7o2_80Hz_7ms_ID_20210615';
% mouse = '2xGC_7o2_80Hz_7ms_ID_20210624/2xGC_7o2_80Hz_7ms_ID_20210624';
% mouse = '8xGC_7o2_80Hz_7ms_ID_20210624';
% datafolder = '/media/data/Marleen/Hypoxia_Data_from_Isma/ExpData/';

datafolder = '/media/mbakker/disk1/Marleen/TheGirlz/';
% mouse = 'Tom';
mouse = 'Jane';
% mouse = 'Katy';
% mouse = 'Nick';

acquisition_norm = '/Normoxia_1';
acquisition_hypox12 = '/Hypox_12';
acquisition_norm2 = '/Normoxia_2';
acquisition_hypox10 = '/Hypox_10';
acquisition_norm3 = '/Normoxia_3';

% currentacq = replace(acquisition_hypox10, '/', '');

path_norm = strcat(datafolder, mouse, acquisition_norm);
path_hypox12 = strcat(datafolder, mouse, acquisition_hypox12);
path_norm2 = strcat(datafolder, mouse, acquisition_norm2);
path_hypox10 = strcat(datafolder, mouse, acquisition_hypox10);
path_norm3 = strcat(datafolder, mouse, acquisition_norm3);

datafolder = path_norm3
cd(datafolder);
videoname = mouse;
% videoname = replace(videoname, '_', ' ');
mkdir Figures;


%% Step B. Image Classification. Maak fluorescence als je dat nog niet gedaan hebt
%only have to do these lines once: 
ImagesClassification(datafolder, datafolder, 1, 1, 1, 0);

%delete frames als nodig is

%% Hemo Correction (step 1)
if( exist('fChanCor.dat', 'file') ) %if youve already done hemocorrection, load file
    fid = fopen('fChanCor.dat');
    dat = fread(fid,inf,'*single');
    Infos = matfile('fluo_475.mat');
    %AcqInfoStream = ReadInfoFile(datafolder);
    dat = reshape(dat,Infos.datSize(1,1), Infos.datSize(1,2),[]);
    fclose(fid);
else
    dat = HemoCorrection(pwd,{'Green','Red','Yellow'});
    fid = fopen('fChanCor.dat','w');
    fwrite(fid,dat,'*single');
    fclose(fid);
end

dat=permute(dat,[2,1,3]);
dims = size(dat);
videoname = strcat(videoname, ', Hemodynamic Correction')


%% Change names of files, make base picture
%because names changed:
if( exist([pwd filesep 'gChan.dat'], 'file') ) %filesep is / -- werkt bij alle systemen, want windows is / en apple is \
    movefile 'gChan.dat' 'green.dat'
end
if( exist([pwd filesep 'Data_Fluo_475.mat'], 'file') ) %filesep is / -- werkt bij alle systemen, want windows is / en apple is \
    movefile 'Data_Fluo_475.mat' 'fluo_475.mat'
end

fid = fopen('green.dat');

AnaMap = fread(fid, dims(1)*dims(2),'*single');
AnaMap = reshape(AnaMap, dims(1),[])';

clear fid;

%check if the right side is up
imagesc(squeeze(dat(:,:,4)))

%% Make mask in a nice way
imagesc(AnaMap)
h= impoly; %dont close, draw mask

Mask = h.createMask;
Im = abs(AnaMap - imfilter(AnaMap,fspecial('gaussian', 32,16),'same','symmetric'));
Im = Im./max(Im(:));

Mask = bwmorph(Mask&(Im<=0.25),'close',inf);
close all
imagesc(Mask)
% imshowpair(Mask,AnaMap)

save('Mask.mat', 'Mask');

load('Mask.mat');

%% Coregistration -- MAKE SURE IT'S THE CORRECT PATHS
% PathMoving = path_hypox;
datN2 = Coregistration(path_norm, datafolder);
dat = datN2; 
% datN2 = Coregistration(path_norm, path_norm_2);
% dat = datN2;

cd(datafolder);
fid = fopen([datafolder filesep 'fChanCor.dat'],'w');
fwrite(fid,dat,'*single');
fclose(fid); %sla coregistered image op als fchancor

%%
load('tform.mat')
AnaMap = imwarp(AnaMap, tform, 'OutputView',imref2d(size(AnaMap))); %transformeer anamap en mask naar coregistration parameters
Mask = imwarp(Mask, tform, 'OutputView',imref2d(size(Mask)));

%to check
Maskn = load(strcat(path_norm,'/Mask.mat'));
imshowpair(Mask,Maskn.Mask);

%% Normalisation & Frequency Filtering
dat = NormalisationFiltering(dat, 0.3, 3, 1); %1 is voor delen door, 0 is voor min voor hbo/hbr

videoname = strcat(videoname, ', Normalisation and Filtering')

%% GSR (Global Signal Regression)
dat = reshape(dat,[], dims(3));
mS = mean(dat(Mask(:),:),1);
X = [ones(size(mS)); mS];
B = X'\dat';
A = (X'*B)';
dat = dat./A;
dat = reshape(dat,dims);
clear h mS X B A;

videoname = strcat(videoname, ', GSR')

%% Spatial filter
if( length(size(dat)) == 2 ) 
    dat = reshape(dat, dims);
end
dat = imgaussfilt(dat,2.5);

videoname = strcat(videoname, ', Spatial Filtering')

%% Define ROI (new way of bruno)
%for old way see klad5
FuncMap = sum(abs(dat-1),3);
P = prctile(FuncMap(Mask(:)),[1 99]);
FuncMap = (FuncMap - P(1))./(P(2) - P(1));
FuncMap(FuncMap<0) = 0;
FuncMap(FuncMap>1) = 1;
ROImanager(FuncMap.*Mask)

% load(strcat(path_norm,'/ROI_.mat'));
load(strcat(path_norm,'/ROI_Stretched.mat'));

%to check the regions of interest
AtlasMask = zeros(size(dat,1),size(dat,2));
for ind = 1:size(ROI_info,2)
    AtlasMask(ROI_info(ind).Stats.ROI_binary_mask) = ind;
end

figh = figure;
ax1 = axes('Parent', figh);
ax2 = axes('Parent', figh);

linkprop([ax1, ax2], {'Position','xlim','ylim'});

% imagesc(ax1, AnaMap); 
imagesc(ax1,FuncMap);
colormap(ax1, 'gray');
axis(ax1, 'image');
axis(ax1, 'off');

imagesc(ax2, AtlasMask, 'AlphaData', 0.5*(AtlasMask>0)); 
colormap(ax2, 'jet');
axis(ax2, 'image');
axis(ax2, 'off');
clear ax1 ax2 figh;
clear h;

%% Correlation Matrix
dat = reshape(dat,dims(1),dims(2),[]);
[CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
% close all

%to get variables with names and timecourses
Names = arrayfun(@(x) AllRois{x,3}, 1:size(AllRois,1), 'UniformOutput', false); %is for loop in principe
Timecourses = reshape([AllRois{:,2}],dims(3),[]) - 1;

save('AllRois.mat', 'AllRois');
% save('AllRoisGSR.mat', 'AllRois');

% load('AllRois.mat', 'AllRois');
%% ROI to plot over brain
%Find indexes of the ROI you want to plot
indexroiBCR = find(contains(Names,'BC_R'));
indexroiBCL = find(contains(Names,'BC_L'));
indexroiM1R = find(contains(Names,'M1_R'));

%clear X Y Tmp Signal name n_segments n_points_per_segment MiddleLine lpass ind* i hpass h fid f 
figh = figure;
ax1 = axes('Parent', figh);
ax2 = axes('Parent', figh);

linkprop([ax1, ax2], 'Position');

imagesc(ax1, AnaMap); 
colormap(ax1, 'gray');
axis(ax1, 'image');
axis(ax1, 'off');

imagesc(ax2, AllRois{indexroiBCR,1} + -1*AllRois{indexroiM1R,1} + -1*AllRois{indexroiBCL,1}, 'AlphaData', 0.8*(AllRois{indexroiBCR,1}+ 0.8*AllRois{indexroiM1R,1} + 0.8*AllRois{indexroiBCL,1})); 
colormap(ax2, 'jet');
axis(ax2, 'image');
axis(ax2, 'off');
clear ax1 ax2 figh;

%% Plot timecourse brain activation per ROI
roiBCR_timecourse = Timecourses(:,indexroiBCR);
plot(roiBCR_timecourse)
title(strcat(AllRois(indexroiBCR,3), ' timecourse'))
%dit is de time course voor de gemiddelde barrelcortex activiteit

roiBCL_timecourse = Timecourses(:,indexroiBCR);
figure()
plot(roiBCL_timecourse)
title(strcat(AllRois(indexroiBCL,3), ' timecourse'))

roiM1R_timecourse = Timecourses(:,indexroiM1R);
figure()
plot(roiM1R_timecourse)
title(strcat(AllRois(indexroiM1R,3), ' timecourse'))

%% Structure time in minutes
%if you want to delete a timewindow, look at klad 7 or before
Time = linspace(0, (48000-1)/20, 48000); %delen door 20 want 20 Hz
Time = reshape(Time,1200,[]); %1200 want 20 Hz x 60 sec - tijd per min
timecorrected = cat(2,Time(1:end));

%% Get correlation per minute - BC and M1
correlated_minute = [];
correlated_minutes = [];
for indS = 1:size(Time,2)
   idx = ismember(timecorrected, Time(:,indS));
   if( ~all(idx==0) )
        correlated_minute = corr(roiBCR_timecourse(idx), roiM1R_timecourse(idx));
        correlated_minutes = [correlated_minutes, correlated_minute]; 
   end
end

plot(correlated_minutes)
% title('correlation barrel cortex - motor cortex per min - right');
title(strcat('Correlation timecourse  ', AllRois(indexroiBCR,3), ' - ', AllRois(indexroiM1R,3), '  per min.'))
subtitle(videoname);
clear correlated_minute correlated_minutes indS idx

%% Seed pixel correlation map - 1 seed (BC)
figure()
if( length(size(dat))>2 )
    dat = reshape(dat,[],dims(3));
end
[rho,pval]=corr(roiBCR_timecourse,dat');
single_seed_corr_map=reshape(rho,[dims(1),dims(2)]);
imagesc(single_seed_corr_map,[0,1])
axis image
colorbar
hold on
colormap jet
title(strcat('Seed pixel correlation map  ', AllRois(indexroiBCR,3)))
subtitle(videoname);

clear rho pval single_seed_corr_map 

dat = reshape(dat, dims);

%% Seed pixel correlation map over minutes - BC
dat = reshape(dat,[],dims(3));
for indS = 1:size(Time,2) %per minuut
    idx = ismember(timecorrected, Time(:,indS));
    if( ~all(idx==0) )
        minutedata = dat(:,idx)-1; %data of one minute
        [rho,pval] = corr(roiBCR_timecourse(idx),minutedata');
        single_seed_corr_map=reshape(rho,[dims(1),dims(2)]);
        Im = abs(AnaMap - imfilter(AnaMap,fspecial('gaussian', 32,16),'same','symmetric'));
        Im = Im./max(Im(:));
        h = subplot(4,10,indS);
        imagesc(single_seed_corr_map, [0 1])
        axis equal
        axis off
        colormap jet
        title(h,['Minute ',num2str(indS)])
   end
end
dat = reshape(dat,dims);
clear rho pval indS idx minutedata single_seed_corr_map h;

%% Interactive seed pixel correlation map
dat = reshape(dat,[],dims(3)); 
datH12 = reshape(datH12,[],dims(3)); 
% cMat = corr(dat(:,1:12000)'); %geef begin en eind frame aan. Frame is 1200 x min.. before hypoxia
cMat = corr(datH12(:,14200:24000)'); %during hypoxia minus first two min (transisiton)
% cMat = corr(dat(:,26200:36000)'); %first 10 min after hypox minus first two min transition
% cMat = corr(dat(:,36000:end)');
CorrViewer(cMat,dims) %aangepast 26/7/21, andere ROI size dus alles met 256 aangepast naar datasize(1) of (2)

clear cMat
dat = reshape(dat,dims(1),dims(2),[]);
%% Standard deviation per minute - BC - plot

figure()
for indS = 1:size(Time,2)
   idx = ismember(timecorrected, Time(:,indS));
   if( ~all(idx==0) )
       standdevpermin(indS) = std(roiBCR_timecourse(idx),0,1);
   end
end
plot(standdevpermin)
title(strcat(AllRois(indexroiBCR,3),' standard deviation'))
subtitle(videoname)
clear standdevpermin indS idx


%% Standard deviation imagesc per minute minus first ten min
dat = reshape(dat, [], dims(3));

minute_stdev_10min = std(dat(:,ismember(timecorrected,reshape(Time(:,1:10),[],1))),0,2);
for indS = 1:size(Time,2)
    idx = ismember(timecorrected, Time(:,indS));
    minutedata = dat(:,idx)-1; %data of one minute
    minute_std = (std(minutedata,0,2)) - minute_stdev_10min;
    minute_std = reshape(minute_std,dims(1), dims(2));
    h = subplot(4,10,indS);
    imagesc(minute_std,[-5e-3 5e-3]); %scale for no gsr
%     imagesc(minute_std,[-7e-3 7e-3]); %scale with gsr
    axis equal
    axis off
    title(h,['Minute ',num2str(indS)])
end
clear minutedata minute_std minute_stdev_10min

dat = reshape(dat, dims);

%% histogram, linegraph, 2d graph
% AllRois = load('AllRoisGSR.mat');
% AllRois = load('AllRois.mat');
% AllRois = AllRois.AllRois;

HistogramInterIntra(AllRois, videoname);
close all
CorrelationLineGraphInterIntra(AllRois, videoname);
close all
Graph2D(AllRois, videoname);
close all


% move figures to right folder

%without GSR
mkdir ./Figures/WithoutGSR
movefile ./Figures/CMatrixHypoxia.png ./Figures/WithoutGSR
movefile ./Figures/CMatrixBefore.png ./Figures/WithoutGSR
movefile ./Figures/CMatrixAfter.png ./Figures/WithoutGSR
movefile ./Figures/Histogram.png ./Figures/WithoutGSR
movefile ./Figures/Scatterplot.png ./Figures/WithoutGSR
movefile ./Figures/MedianLineGraph.png ./Figures/WithoutGSR
movefile ./Figures/MeanLineGraph.png ./Figures/WithoutGSR
movefile ./Figures/Graph2D.png ./Figures/WithoutGSR

%with GSR
mkdir ./Figures/WithGSR
movefile ./Figures/CMatrixHypoxia.png ./Figures/WithGSR
movefile ./Figures/CMatrixBefore.png ./Figures/WithGSR
movefile ./Figures/CMatrixAfter.png ./Figures/WithGSR
movefile ./Figures/Histogram.png ./Figures/WithGSR
movefile ./Figures/Scatterplot.png ./Figures/WithGSR
movefile ./Figures/MedianLineGraph.png ./Figures/WithGSR
movefile ./Figures/MeanLineGraph.png ./Figures/WithGSR
movefile ./Figures/Graph2D.png ./Figures/WithGSR

%HbOHbR
mkdir ./Figures/HbOHbR
movefile ./Figures/CMatrixHypoxia.png ./Figures/HbOHbR
movefile ./Figures/CMatrixBefore.png ./Figures/HbOHbR
movefile ./Figures/CMatrixAfter.png ./Figures/HbOHbR
movefile ./Figures/Histogram.png ./Figures/HbOHbR
movefile ./Figures/Scatterplot.png ./Figures/HbOHbR
movefile ./Figures/MedianLineGraph.png ./Figures/HbOHbR
movefile ./Figures/MeanLineGraph.png ./Figures/HbOHbR
movefile ./Figures/Graph2D.png ./Figures/HbOHbR

%% Visualisation data
dat = reshape(dat,dims(1),dims(2),[]);
figure;
for ind = 32500:1:34400
    imagesc(abs((squeeze(dat(:,:,ind)))),[0.95 1.05]);
    title(int2str(ind));
    axis image
    pause(0.01);
end
    