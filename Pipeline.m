%% Klad 9 - All mice, per acquisition
%% Get right acquisition
% batch = '/media/mbakker/data1/Hypoxia/TheGirlz/';
% Mice = {'Tom', 'Jane', 'Nick'}
% Mice = {'Nick'}
% 
% batch = '/media/mbakker/data1/Hypoxia/TheBoys/';
% % Mice = { 'Chiploos', '087', '227', '552'}; 
% % Mice = {'552'};
% % Mice = {'1Stripe_normoxia3_20210928', '2Stripe_normoxia3_20210928', '3Stripe_normoxia3_20210928','Chiploos_normoxia3_20210928'};
% % batch = '/media/mbakker/data1/Hypoxia/TheBoys';
% % acquisition = '/Normoxia_3';
% % Mice = { '227' }; 
% % 
% acquisition = '/Normoxia_1'
% acquisition = '/Hypox_12'

%% Preprocessing (imageclassification, coregistration within mouse, hemodynamic correction)
cd(batch)
% PreProcessing(acquisition, batch, Mice);

% disp('donethis part')
%%

for index = 1:size(Mice,2)
    mouse = Mice{index}
    datafolder = batch;
    datafolder = strcat(datafolder, mouse, acquisition);
    cd(datafolder);
    
    if ~exist('fChanCor.dat','file')
        PreProcessing(acquisition, batch, {mouse});
    end
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
%         dat=permute(dat,[2,1,3]);
        disp('Coregistration within has NOT been done')
    end
%     
%     if contains(acquisition, 'Normoxia_1')
%         dat = permute(dat, [2 1 3]);
%     end
    
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
        close all
    end

    %% Coregistration between acquisitions
    % check Coregistration - welke kant is boven 
    if  contains(acquisition, 'Normoxia_1')
        disp('Normoxia 1 acquisition, so no coregistration')
    elseif ( exist([pwd filesep 'tform.mat'], 'file') )
        fprintf('coregistration between acquisitions already done')
        load('tform.mat')
        AnaMap = imwarp(AnaMap, tform, 'OutputView',imref2d(size(AnaMap))); %transformeer anamap en mask naar coregistration parameters
        Mask = imwarp(Mask, tform, 'OutputView',imref2d(size(Mask))); %zelfde voor mask
        
    else            
        path_norm = strcat(batch, mouse, '/Normoxia_1');
        datnorm = Coregistration(path_norm, datafolder);
        
        cd(datafolder); %niet nodig denk ik maar toch maar doen voor de zekerheid
        fid = fopen([datafolder filesep 'fChanCor.dat'],'w');
        fwrite(fid,dat,'*single');
        fclose(fid); %sla coregistered image op als fchancor
        fprintf('coregistration between acquisitions done')
        
        load('tform.mat')
        AnaMap = imwarp(AnaMap, tform, 'OutputView',imref2d(size(AnaMap))); %transformeer anamap en mask naar coregistration parameters
        Mask = imwarp(Mask, tform, 'OutputView',imref2d(size(Mask))); %zelfde voor mask
        
        %     %to check
        %     Maskn = load(strcat(path_norm,'/Mask.mat'));
        %     imshowpair(Mask,Maskn.Mask);
    end
    close all
    videoname = strcat(videoname, ', Coreg')
    

    %% Normalisation and frequency filtering
    dat = NormalisationFiltering(dat, 0.3, 3, 1); %1 is voor delen door, 0 is voor min voor hbo/hbr

    videoname = strcat(videoname, ', Normalisation and filtering')
    
    %% ROI
    % Make a map based on the functional data you gathered
    path_norm = [batch filesep mouse filesep 'Normoxia_1'];
    FuncMap = sum(abs(dat-1),3);
    P = prctile(FuncMap(Mask(:)),[1 99]);
    FuncMap = (FuncMap - P(1))./(P(2) - P(1));
    FuncMap(FuncMap<0) = 0;
    FuncMap(FuncMap>1) = 1;
    
%     if  contains(acquisition, 'Normoxia_1') %als het Norm1 is moet je nog ROI maken
%     if exist(strcat(path_norm,'/ROI_.mat'));
    if ( exist([path_norm filesep '/ROI_149.mat'], 'file') )
        load(strcat(path_norm,'/ROI_149.mat'));
    else
        ROImanager(FuncMap.*Mask)
        load(strcat(path_norm,'/ROI_149.mat'));
    end
    
    %% Correlation matrix without GSR
    mkdir('Figures')
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

    mkdir ./Figures/WithoutGSR
    movefile ./Figures/CMatrixHypoxia.png ./Figures/WithoutGSR
    movefile ./Figures/CMatrixBefore.png ./Figures/WithoutGSR
    movefile ./Figures/CMatrixAfter.png ./Figures/WithoutGSR
    movefile ./Figures/Histogram.png ./Figures/WithoutGSR
    movefile ./Figures/Scatterplot.png ./Figures/WithoutGSR
    movefile ./Figures/MedianLineGraph.png ./Figures/WithoutGSR
    movefile ./Figures/MeanLineGraph.png ./Figures/WithoutGSR
    movefile ./Figures/Graph2D.png ./Figures/WithoutGSR

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

    mkdir ./Figures/WithGSR
    movefile ./Figures/CMatrixHypoxia.png ./Figures/WithGSR
    movefile ./Figures/CMatrixBefore.png ./Figures/WithGSR
    movefile ./Figures/CMatrixAfter.png ./Figures/WithGSR
    movefile ./Figures/Histogram.png ./Figures/WithGSR
    movefile ./Figures/Scatterplot.png ./Figures/WithGSR
    movefile ./Figures/MedianLineGraph.png ./Figures/WithGSR
    movefile ./Figures/MeanLineGraph.png ./Figures/WithGSR
    movefile ./Figures/Graph2D.png ./Figures/WithGSR

end



