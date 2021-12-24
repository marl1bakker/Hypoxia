%% HbO/HbR
% voor oude versie zie hbohbr.m

% batch = '/media/mbakker/data1/Hypoxia/TheBoys/';
batch = '/media/mbakker/data1/Hypoxia/TheGirlz/';

% Mice = { 'Chiploos', '087', '227'};
% Mice = { '227' };
Mice = {'Nick'};
% Mice = {'Nick', 'Jane', 'Tom', 'Katy'};

% acquisition = '/Normoxia_1'
% acquisition = '/Hypox_12'
% acquisition = '/Normoxia_2'
% acquisition = '/Hypox_10'
% acquisition = '/Normoxia_3'
% acquisition = '/Hypox_8_1'
acquisition = '/Normoxia_4'
% acquisition = '/Hypox_8_2';

acquisition_norm = '/Normoxia_1';

cd(batch)

for index = 1:size(Mice,2)
    mouse = Mice{index}
    datafolder = batch;
    datafolder = strcat(datafolder, mouse, acquisition);
    cd(datafolder);
    videoname = mouse;
    path_norm = strcat(batch, mouse, acquisition_norm);
    
    Infos = matfile('fluo_475.mat');
    dims = [Infos.datSize(1,1), Infos.datSize(1,2), Infos.datLength];
    
    if( exist([pwd filesep 'Hbo.mat'], 'file') )
        disp('HbO and HbR already saved but not transformed and not *1e6')
        disp('transforming and resaving as HbO and HbR.mat')
        load('Hbo.mat')
        load('Hbr.mat')
        
        if  contains(acquisition, 'Normoxia_1')
            disp('Normoxia 1 acquisition, so no coregistration')
        elseif ( exist([pwd filesep 'tform.mat'], 'file') )
            load('tform.mat')
            for ind = 1:size(HbO,3)
                HbO(:,:,ind) = imwarp(squeeze(HbO(:,:,ind)), tform, 'OutputView',imref2d([size(HbO,1), size(HbO,2)]));
                HbR(:,:,ind) = imwarp(squeeze(HbR(:,:,ind)), tform, 'OutputView',imref2d([size(HbR,1), size(HbR,2)]));
            end
        end
        
        imshowpair(HbO(:,:,1),HbR(:,:,1));
        
        HbR = HbR*1e6; %ga van mol naar micromol
        HbO = HbO*1e6;
        
        delete('Hbo.mat')
        delete('Hbr.mat')
        save('HbO.mat', 'HbO', '-v7.3');
        save('HbR.mat', 'HbR', '-v7.3');
        load('HbO.mat')
        load('HbR.mat')
    else
        %          Get data
        AcqInfoStream = ReadInfoFile(datafolder);
        fid = fopen('red.dat');
        datr = fread(fid,inf,'*single');
        datr = reshape(datr,AcqInfoStream.Width,AcqInfoStream.Height,[]);
        fclose(fid);
        datr = -log(datr./mean(datr(:,:,1:12000),3));
        C = datr(:);
        clear datr;
        
        fid = fopen('green.dat');
        datg = fread(fid,inf,'*single');
        datg = reshape(datg,AcqInfoStream.Width,AcqInfoStream.Height,[]);
        datg = -log(datg./mean(datg(:,:,1:12000),3));
        C = [C, datg(:)];
        clear datg;
        
        fid = fopen('yellow.dat');
        daty = fread(fid,inf,'*single');
        daty = reshape(daty,AcqInfoStream.Width,AcqInfoStream.Height,[]);
        fclose(fid);
        daty = -log(daty./mean(daty(:,:,1:12000),3));
        C = [C, daty(:)];
        clear daty;
        
        % calculate stuff
        eps = ioi_epsilon_pathlength('Hillman', 100, 60, 40, 0); %get pathlengths
        Ainv = pinv(eps); %pseudoinverse of eps matrix (inverse niet mogelijk, want niet vierkant, dus soort benadering - Moore-penrose))
        
        Hbs = Ainv*C';
        
        HbO = reshape(Hbs(1,:), dims(1),dims(2),[]);
        HbR = reshape(Hbs(2,:), dims(1),dims(2),[]);
        clear Hbs C
        
        % Normalisation and filtering
        % HbO = NormalisationFiltering(HbO, 1/120, 1/10, 1); %nul is voor delen door, 1 is voor min voor hbo/hbr
        
        if  contains(acquisition, 'Normoxia_1')
            disp('Normoxia 1 acquisition, so no coregistration')
        elseif ( exist([pwd filesep 'tform.mat'], 'file') )
            load('tform.mat')
            for ind = 1:size(HbO,3)
                HbO(:,:,ind) = imwarp(squeeze(HbO(:,:,ind)), tform, 'OutputView',imref2d([size(HbO,1), size(HbO,2)]));
                HbR(:,:,ind) = imwarp(squeeze(HbR(:,:,ind)), tform, 'OutputView',imref2d([size(HbR,1), size(HbR,2)]));
            end
        end
        
        imshowpair(HbO(:,:,1),HbR(:,:,1));
        
        HbR = HbR*1e6; %ga van mol naar micromol
        HbO = HbO*1e6;
        
        imagesc(HbO(:,:,1))
        answer = questdlg('Does it make sense?', ...
            'HbO/HbR', ...
            'Yes','No','Yes');
        % Handle response
        switch answer
            case 'Yes'
                % Save Stuff
                close all
                save('HbO.mat', 'HbO', '-v7.3');
                save('HbR.mat', 'HbR', '-v7.3');
                load('HbO.mat')
                load('HbR.mat')
            case 'No'
                close all
                HbO = permute(HbO,[2,1,3]);
                HbR = permute(HbR,[2,1,3]);
                imagesc(HbO(:,:,1))
                uiwait(gcf)
                save('HbO.mat', 'HbO', '-v7.3');
                save('HbR.mat', 'HbR', '-v7.3');
                load('HbO.mat')
                load('HbR.mat')
        end
    end
    
    load(strcat(path_norm,'/ROI_.mat'));
    
    %% For AllRois
    if( exist([pwd filesep 'AllRoisHbO.mat'], 'file') )
        AllRoisHbR = load('AllRoisHbR.mat');
        AllRoisHbR = AllRoisHbR.AllRois;
        
        AllRoisHbO = load('AllRoisHbO.mat');
        AllRoisHbO = AllRoisHbO.AllRois;
        
    else
        % Make AllRois variables
        load(strcat(path_norm,'/ROI_.mat'));
        
        %HbR
        dat = reshape(HbR,dims);
        [CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
        save('AllRoisHbR.mat', 'AllRois');
        clear AllRois
        close all
        mkdir ./Figures/HbR
        movefile ./Figures/CMatrixHypoxia.png ./Figures/HbR
        movefile ./Figures/CMatrixBefore.png ./Figures/HbR
        movefile ./Figures/CMatrixAfter.png ./Figures/HbR
        
        %HbO
        dat = reshape(HbO,dims);
        [CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
        save('AllRoisHbO.mat', 'AllRois');
        clear AllRois
        close all
        
        mkdir ./Figures/HbO
        movefile ./Figures/CMatrixHypoxia.png ./Figures/HbO
        movefile ./Figures/CMatrixBefore.png ./Figures/HbO
        movefile ./Figures/CMatrixAfter.png ./Figures/HbO
        
        AllRoisHbR = load('AllRoisHbR.mat');
        AllRoisHbR = AllRoisHbR.AllRois;
        
        AllRoisHbO = load('AllRoisHbO.mat');
        AllRoisHbO = AllRoisHbO.AllRois;
        
    end
    
    %% plot figures
    % make plots for M1R and BCL
    Names = arrayfun(@(x) AllRoisHbR{x,3}, 1:size(AllRoisHbR,1), 'UniformOutput', false); %is for loop in principe
    indexroiMC1R = find(contains(Names,'M1_R'));
    indexroiBCL = find(contains(Names,'BC_L'));
    
    M1R_HbR = AllRoisHbR{indexroiMC1R,2};
    BCL_HbR = AllRoisHbR{indexroiBCL,2};
    
    M1R_HbO = AllRoisHbO{indexroiMC1R,2};
    BCL_HbO = AllRoisHbO{indexroiBCL,2};
    
    Hb_oneseed([M1R_HbO; M1R_HbR; M1R_HbR+M1R_HbO]')
    saveas(gcf, './Figures/M1R.png');
    close all
    Hb_oneseed([BCL_HbO; BCL_HbR; BCL_HbR+BCL_HbO]')
    saveas(gcf, './Figures/BCL.png');
    close all
    
    %%
    figuretitleHbR = strcat('HbR ', mouse);
    HistogramInterIntra(AllRoisHbR, figuretitleHbR);
    close all
    CorrelationLineGraphInterIntra(AllRoisHbR, figuretitleHbR);
    close all
    Graph2D(AllRoisHbR, figuretitleHbR);
    close all
    
    movefile ./Figures/Histogram.png ./Figures/HbR
    movefile ./Figures/Scatterplot.png ./Figures/HbR
    movefile ./Figures/MedianLineGraph.png ./Figures/HbR
    movefile ./Figures/MeanLineGraph.png ./Figures/HbR
    movefile ./Figures/Graph2D.png ./Figures/HbR
    
    figuretitleHbO = strcat('HbO ', mouse);
    HistogramInterIntra(AllRoisHbO, figuretitleHbO);
    close all
    CorrelationLineGraphInterIntra(AllRoisHbO, figuretitleHbO);
    close all
    Graph2D(AllRoisHbO, figuretitleHbO);
    close all
    
    movefile ./Figures/Histogram.png ./Figures/HbO
    movefile ./Figures/Scatterplot.png ./Figures/HbO
    movefile ./Figures/MedianLineGraph.png ./Figures/HbO
    movefile ./Figures/MeanLineGraph.png ./Figures/HbO
    movefile ./Figures/Graph2D.png ./Figures/HbO
    
    %% Images of HbO/HbR/HbT
    %% Average over a minute hypox vs a minute normox
    if  contains(acquisition, 'Normoxia_1')
        load('Mask.mat')
    elseif ( exist([pwd filesep 'tform.mat'], 'file') )
        load('tform.mat')
        load('Mask.mat');
        Mask = imwarp(Mask, tform, 'OutputView',imref2d(size(Mask)));
    end
    
    %to know when the hypoxia period was
    if( exist([pwd filesep 'Acquisition_information.txt'], 'file') )
        fileID = fopen('Acquisition_information.txt');
        bstop = 0;
        while (bstop == 0) || ~feof(fileID)
            Textline = fgetl(fileID);
            if endsWith(Textline,'min')
                bstop = 1;
            end
        end
        hypoxmin = str2num(Textline(1:2));
    else
        hypoxmin = 10;
    end
    
    hypoxbegin = hypoxmin * 60 * 20;
    hypoxend = hypoxbegin + 12000;
    
    hypoxminHbO = (HbO(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20))) .* Mask; %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
    hypoxminHbR = (HbR(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20))) .* Mask; %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
    normoxminHbO = (HbO(:,:,(5*60*20):(6*60*20))) .* Mask; %minute 5 to 6
    normoxminHbR = (HbR(:,:,(5*60*20):(6*60*20))) .* Mask;
    
    % hypoxminHbO = HbO(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20)); %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
    % hypoxminHbR = HbR(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20)); %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
    % normoxminHbO = HbO(:,:,(5*60*20):(6*60*20)); %minute 5 to 6
    % normoxminHbR = HbR(:,:,(5*60*20):(6*60*20));
    % hypoxminHbO = hypoxminHbO .* Mask;
    % hypoxminHbR = hypoxminHbR .* Mask;
    % normoxminHbO = normoxminHbO .* Mask;
    % normoxminHbR = normoxminHbR .* Mask;
    
    subplot(1,2,1)
    imagesc(mean(normoxminHbO,3),[-5 18])
%     imagesc(mean(normoxminHbO, 3), [])
    colorbar
    hold on
    imagesc(zeros(192,192,3),'AlphaData', ~Mask);
    axis image
    axis off
    title('HbO Normoxia')
    subplot(1,2,2)
    imagesc(mean(hypoxminHbO,3), [-5 18])
    colorbar
    hold on
    imagesc(zeros(192,192,3),'AlphaData', ~Mask);
    axis image
    axis off
    title('HbO Hypoxia')
    saveas(gcf, './Figures/HbONormHypox.png');
    close all
    
    subplot(1,2,1)
    imagesc(mean(normoxminHbR,3),[-5 18])
    colorbar
    hold on
    imagesc(zeros(192,192,3),'AlphaData', ~Mask);
    axis image
    axis off
    title('HbR Normoxia')
    subplot(1,2,2)
    imagesc(mean(hypoxminHbR,3), [-5 18])
    colorbar
    hold on
    imagesc(zeros(192,192,3),'AlphaData', ~Mask);
    axis image
    axis off
    title('HbR Hypoxia')
    saveas(gcf, './Figures/HbRNormHypox.png');
    close all
    
end


%% Visualisation data
% HbO = reshape(HbO,dims(1),dims(2),[]);
% figure;
% for ind = 20000:20:25000
%     imagesc((squeeze(HbO(:,:,ind))), [-15 15]);
%     title(int2str(ind));
%     axis image
%     pause(0.01);
% end
%
% HbR = reshape(HbR,dims(1),dims(2),[]);
% figure;
% for ind = 1:1:12000
%     imagesc((squeeze(HbR(:,:,ind))), [-15 15]);
%     title(int2str(ind));
%     axis image
%     pause(0.01);
% end
%
% AcqInfoStream = ReadInfoFile(datafolder);
% fid = fopen('green.dat');
% datg = fread(fid,inf,'*single');
% datg = reshape(datg,dims(1),dims(2),[]);
%
% AcqInfoStream = ReadInfoFile(datafolder);
% fid = fopen('green.dat');
% datg2 = fread(fid,inf,'*single');
% datg2 = reshape(datg2,dims(1),dims(2),[]);
% datg2 = datg2 ./ mean(datg2, 3);
% figure;
% for ind = 1:1:12000
%     imagesc((squeeze(datg2(:,:,ind))));
%     title(int2str(ind));
%     axis image
%     pause(0.01);
% end
%
% fid = fopen('red.dat');
% datr = fread(fid,inf,'*single');
% datr = reshape(datr,dims(1),dims(2),[]);
% datr = datr - mean(datr, 3);
% figure;
% for ind = 1:1:12000
%     imagesc((squeeze(datr(:,:,ind))));
%     title(int2str(ind));
%     axis image
%     pause(0.01);
% end
%
% fid = fopen('yellow.dat');
% daty = fread(fid,inf,'*single');
% daty = reshape(daty,dims(1),dims(2),[]);
% daty = daty - mean(daty, 3);
% figure;
% for ind = 1:1:12000
%     imagesc((squeeze(daty(:,:,ind))));
%     title(int2str(ind));
%     axis image
%     pause(0.01);
% end
%
% fid = fopen('fluo_475.dat');
% datf = fread(fid,inf,'*single');
% datf = reshape(datf,dims(1),dims(2),[]);
% datf = datf - mean(datf, 3);
% figure;
% for ind = 1:1:12000
%     imagesc((squeeze(datf(:,:,ind))));
%     title(int2str(ind));
%     axis image
%     pause(0.01);
% end


