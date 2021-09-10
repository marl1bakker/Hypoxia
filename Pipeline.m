%% Klad 9 - All mice, per acquisition
%% Get right acquisition
datafolder = '/media/mbakker/disk1/Marleen/TheGirlz/';
Mice = {'Tom','Nick', 'Jane','Katy'}
% Mice = {'Tom'}

% acquisition = '/Hypox_8';
% acquisition = '/Normoxia_1';
% acquisition = '/Normoxia_4';

% acquisition = '/Normoxia_3';
acquisition = '/Hypox_10';

%% Preprocessing (imageclassification, coregistration within mouse, hemodynamic correction)

PreProcessing(acquisition);
disp('donethis part')
%%

for index = 1:size(Mice,2)
    mouse = Mice{index}
    datafolder = strcat(datafolder, mouse, acquisition);
    cd(datafolder);
    videoname = mouse;
    
    %% load hemocorrected data
    fid = fopen('fChanCor.dat');
    dat = fread(fid,inf,'*single');
    Infos = matfile('fluo_475.mat');
    %AcqInfoStream = ReadInfoFile(datafolder);
    dat = reshape(dat,Infos.datSize(1,1), Infos.datSize(1,2),[]);
    fclose(fid);
    
    if( exist([pwd filesep 'IntraCoReg.mat'], 'file') )
        disp('Coregistration within has been done')
    else
        dat=permute(dat,[2,1,3]);
        disp('Coregistration within has NOT been done')
    end
    
    dims = size(dat);
    videoname = strcat(videoname, ', Hemodynamic Correction')

    %% Make or load mask
    fid = fopen('green.dat'); %maak anatomical map
    AnaMap = fread(fid, dims(1)*dims(2),'*single');
    AnaMap = reshape(AnaMap, dims(1),[])';
    
    if( exist([pwd filesep 'IntraCoReg.mat'], 'file') )
        AnaMap = permute(AnaMap, [2,1,3]); %bij het doen van coreg flip je de image, dus nog een keer flippen voor dit
    end
    
    clear fid;
    
    if( exist([pwd filesep 'Mask.mat'], 'file') )
        load('Mask.mat');
    else
        imagesc(AnaMap)
        h= impoly; %dont close, draw mask
        Mask = h.createMask;
        Im = abs(AnaMap - imfilter(AnaMap,fspecial('gaussian', 32,16),'same','symmetric'));
        Im = Im./max(Im(:));
        Mask = bwmorph(Mask&(Im<=0.25),'close',inf);
        close all
        imagesc(Mask)
        save('Mask.mat', 'Mask');
        load('Mask.mat');
    end

    %% Coregistration between acquisitions
    if  contains(acquisition, 'Normoxia_1')
        disp('Normoxia 1 acquisition, so no coregistration')
    else
        path_norm = strcat('/media/mbakker/disk1/Marleen/TheGirlz/', mouse, '/Normoxia_1');
        datnorm = Coregistration(path_norm, datafolder);
        
        cd(datafolder); %niet nodig denk ik maar toch maar doen voor de zekerheid
        fid = fopen([datafolder filesep 'fChanCor.dat'],'w');
        fwrite(fid,dat,'*single');
        fclose(fid); %sla coregistered image op als fchancor
    end
    
    load('tform.mat')
    AnaMap = imwarp(AnaMap, tform, 'OutputView',imref2d(size(AnaMap))); %transformeer anamap en mask naar coregistration parameters
    Mask = imwarp(Mask, tform, 'OutputView',imref2d(size(Mask))); %zelfde voor mask

%     %to check
%     Maskn = load(strcat(path_norm,'/Mask.mat'));
%     imshowpair(Mask,Maskn.Mask);

    videoname = strcat(videoname, ', Coreg')

    %% Normalisation and frequency filtering
    dat = NormalisationFiltering(dat, 0.3, 3, 1); %1 is voor delen door, 0 is voor min voor hbo/hbr

    videoname = strcat(videoname, ', Normalisation and filtering')
    
    %% ROI
    % Make a map based on the functional data you gathered
    path_norm = ['/media/mbakker/disk1/Marleen/TheGirlz' filesep mouse filesep 'Normoxia_1'];
    FuncMap = sum(abs(dat-1),3);
    P = prctile(FuncMap(Mask(:)),[1 99]);
    FuncMap = (FuncMap - P(1))./(P(2) - P(1));
    FuncMap(FuncMap<0) = 0;
    FuncMap(FuncMap>1) = 1;
    
    if( exist([pwd filesep 'Mask.mat'], 'file') )
        %         load(strcat(path_norm,'/ROI_.mat'));
        load(strcat(path_norm,'/ROI_Stretched.mat'));
    else
        ROImanager(FuncMap.*Mask)
        load(strcat(path_norm,'/ROI_Stretched.mat'));
    end
    
    %% Correlation matrix without GSR
    dat = reshape(dat,dims(1),dims(2),[]);
    [CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
    close all
    
    %to get variables with names and timecourses
    Names = arrayfun(@(x) AllRois{x,3}, 1:size(AllRois,1), 'UniformOutput', false); %is for loop in principe
    Timecourses = reshape([AllRois{:,2}],dims(3),[]) - 1;
    
    save('AllRois.mat', 'AllRois');
    load('AllRois.mat', 'AllRois');

    %% Make and safe figures
    HistogramInterIntra(AllRois, videoname);
    close all
    CorrelationLineGraphInterIntra(AllRois, videoname);
    close all
    Graph2D(AllRois, videoname);
    close all

    mkdir ./Figures/WithoutGSRstretchedROI
    movefile ./Figures/CMatrixHypoxia.png ./Figures/WithoutGSRstretchedROI
    movefile ./Figures/CMatrixBefore.png ./Figures/WithoutGSRstretchedROI
    movefile ./Figures/CMatrixAfter.png ./Figures/WithoutGSRstretchedROI
    movefile ./Figures/Histogram.png ./Figures/WithoutGSRstretchedROI
    movefile ./Figures/Scatterplot.png ./Figures/WithoutGSRstretchedROI
    movefile ./Figures/MedianLineGraph.png ./Figures/WithoutGSRstretchedROI
    movefile ./Figures/MeanLineGraph.png ./Figures/WithoutGSRstretchedROI
    movefile ./Figures/Graph2D.png ./Figures/WithoutGSRstretchedROI

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
    
    %% Correlation matrix with GSR
    dat = reshape(dat,dims(1),dims(2),[]);
    [CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
    close all
    
    %to get variables with names and timecourses
    Names = arrayfun(@(x) AllRois{x,3}, 1:size(AllRois,1), 'UniformOutput', false); %is for loop in principe
    Timecourses = reshape([AllRois{:,2}],dims(3),[]) - 1;
    
    save('AllRoisGSR.mat', 'AllRois');
    load('AllRoisGSR.mat', 'AllRois');

    %% Make and safe figures
    HistogramInterIntra(AllRois, videoname);
    close all
    CorrelationLineGraphInterIntra(AllRois, videoname);
    close all
    Graph2D(AllRois, videoname);
    close all

    mkdir ./Figures/WithGSRstretchedROI
    movefile ./Figures/CMatrixHypoxia.png ./Figures/WithGSRstretchedROI
    movefile ./Figures/CMatrixBefore.png ./Figures/WithGSRstretchedROI
    movefile ./Figures/CMatrixAfter.png ./Figures/WithGSRstretchedROI
    movefile ./Figures/Histogram.png ./Figures/WithGSRstretchedROI
    movefile ./Figures/Scatterplot.png ./Figures/WithGSRstretchedROI
    movefile ./Figures/MedianLineGraph.png ./Figures/WithGSRstretchedROI
    movefile ./Figures/MeanLineGraph.png ./Figures/WithGSRstretchedROI
    movefile ./Figures/Graph2D.png ./Figures/WithGSRstretchedROI

end



