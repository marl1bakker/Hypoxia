function AllRoisAndFigures(DataFolder, ROIpath)
%% To make AllRois and HbO/HbR stuff
load(ROIpath);
disp(DataFolder)
if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

%% load data
fid = fopen([DataFolder 'fChanCor.dat']);
dat = fread(fid,inf,'*single');
Infos = matfile([DataFolder 'fluo_475.mat']);
%AcqInfoStream = ReadInfoFile(datafolder);
dat = reshape(dat,Infos.datSize(1,1), Infos.datSize(1,2),[]);
fclose(fid);
dims = size(dat)

 %% Correlation matrix without GSR
 mkdir([DataFolder 'Figures'])
 dat = reshape(dat,dims(1),dims(2),[]);
 [CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,DataFolder,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
 close all
 
 %to get variables with names and timecourses
 Names = arrayfun(@(x) AllRois{x,3}, 1:size(AllRois,1), 'UniformOutput', false); %is for loop in principe
 Timecourses = reshape([AllRois{:,2}],dims(3),[]) - 1;
 
 save([DataFolder 'AllRois.mat'], 'AllRois');
 load([DataFolder 'AllRois.mat'], 'AllRois');
 
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

 %%
%  %% HbO/HbR
% % voor oude versie zie hbohbr.m
% 
% 
% 
% %     path_norm = strcat(batch, mouse, acquisition_norm);
% 
% AcqInfoStream = ReadInfoFile(DataFolder);
% fid = fopen([DataFolder 'red.dat']);
% datr = fread(fid,inf,'*single');
% datr = reshape(datr,AcqInfoStream.Width,AcqInfoStream.Height,[]);
% fclose(fid);
% datr = -log(datr./mean(datr(:,:,1:12000),3));
% C = datr(:);
% clear datr;
% 
% fid = fopen([DataFolder 'green.dat']);
% datg = fread(fid,inf,'*single');
% datg = reshape(datg,AcqInfoStream.Width,AcqInfoStream.Height,[]);
% datg = -log(datg./mean(datg(:,:,1:12000),3));
% C = [C, datg(:)];
% clear datg;
% 
% fid = fopen([DataFolder 'yellow.dat']);
% daty = fread(fid,inf,'*single');
% daty = reshape(daty,AcqInfoStream.Width,AcqInfoStream.Height,[]);
% fclose(fid);
% daty = -log(daty./mean(daty(:,:,1:12000),3));
% C = [C, daty(:)];
% clear daty;
%         
% % calculate stuff
% eps = ioi_epsilon_pathlength('Hillman', 100, 60, 40, 0); %get pathlengths
% Ainv = pinv(eps); %pseudoinverse of eps matrix (inverse niet mogelijk, want niet vierkant, dus soort benadering - Moore-penrose))
% 
% Hbs = Ainv*C';
% 
% HbO = reshape(Hbs(1,:), dims(1),dims(2),[]);
% HbR = reshape(Hbs(2,:), dims(1),dims(2),[]);
% clear Hbs C
% 
% % Normalisation and filtering
% % HbO = NormalisationFiltering(HbO, 1/120, 1/10, 1); %nul is voor delen door, 1 is voor min voor hbo/hbr
% 
% 
% imshowpair(HbO(:,:,1),HbR(:,:,1));
% 
% HbR = HbR*1e6; %ga van mol naar micromol
% HbO = HbO*1e6;
% 
% imagesc(HbO(:,:,1))
% answer = questdlg('Does it make sense?', ...
%     'HbO/HbR', ...
%     'Yes','No','Yes');
% % Handle response
% switch answer
%     case 'Yes'
%         % Save Stuff
%         close all
%         save('HbO.mat', 'HbO', '-v7.3');
%         save('HbR.mat', 'HbR', '-v7.3');
%         load('HbO.mat')
%         load('HbR.mat')
%     case 'No'
%         close all
%         HbO = permute(HbO,[2,1,3]);
%         HbR = permute(HbR,[2,1,3]);
%         imagesc(HbO(:,:,1))
%         uiwait(gcf)
%         save('HbO.mat', 'HbO', '-v7.3');
%         save('HbR.mat', 'HbR', '-v7.3');
%         load('HbO.mat')
%         load('HbR.mat')
% end
% end
%     
%     %% For AllRois
% %     if( exist([pwd filesep 'AllRoisHbO.mat'], 'file') )
% %         AllRoisHbR = load('AllRoisHbR.mat');
% %         AllRoisHbR = AllRoisHbR.AllRois;
% %         
% %         AllRoisHbO = load('AllRoisHbO.mat');
% %         AllRoisHbO = AllRoisHbO.AllRois;
% %         
% %     else
%         % Make AllRois variables
% 
%         
%         %HbR
%         HbR = reshape(HbR,dims);
%         [CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
%         save('AllRoisHbR.mat', 'AllRois');
%         clear AllRois
%         close all
%         mkdir ./Figures/HbR
%         movefile ./Figures/CMatrixHypoxia.png ./Figures/HbR
%         movefile ./Figures/CMatrixBefore.png ./Figures/HbR
%         movefile ./Figures/CMatrixAfter.png ./Figures/HbR
%         
%         %HbO
%         dat = reshape(HbO,dims);
%         [CorrMatrix,CorrMatrixBefore,CorrMatrixHypox,CorrMatrixAfter,CorrMatrixHypoxMinusBefore,AllRois] = CorrelationMatrix(dat,ROI_info, {'CMatrixBefore','CMatrixHypox','CMatrixAfter','CMatrixDiff'});
%         save('AllRoisHbO.mat', 'AllRois');
%         clear AllRois
%         close all
%         
%         mkdir ./Figures/HbO
%         movefile ./Figures/CMatrixHypoxia.png ./Figures/HbO
%         movefile ./Figures/CMatrixBefore.png ./Figures/HbO
%         movefile ./Figures/CMatrixAfter.png ./Figures/HbO
%         
%         AllRoisHbR = load('AllRoisHbR.mat');
%         AllRoisHbR = AllRoisHbR.AllRois;
%         
%         AllRoisHbO = load('AllRoisHbO.mat');
%         AllRoisHbO = AllRoisHbO.AllRois;
%         
% %     end
%     
%     %% plot figures
%     % make plots for M1R and BCL
%     Names = arrayfun(@(x) AllRoisHbR{x,3}, 1:size(AllRoisHbR,1), 'UniformOutput', false); %is for loop in principe
%     indexroiMC1R = find(contains(Names,'M1_R'));
%     indexroiBCL = find(contains(Names,'BC_L'));
%     
%     M1R_HbR = AllRoisHbR{indexroiMC1R,2};
%     BCL_HbR = AllRoisHbR{indexroiBCL,2};
%     
%     M1R_HbO = AllRoisHbO{indexroiMC1R,2};
%     BCL_HbO = AllRoisHbO{indexroiBCL,2};
%     
%     Hb_oneseed([M1R_HbO; M1R_HbR; M1R_HbR+M1R_HbO]')
%     saveas(gcf, './Figures/M1R.png');
%     close all
%     Hb_oneseed([BCL_HbO; BCL_HbR; BCL_HbR+BCL_HbO]')
%     saveas(gcf, './Figures/BCL.png');
%     close all
%     
%     %%
%     figuretitleHbR = strcat('HbR ', mouse);
%     HistogramInterIntra(AllRoisHbR, figuretitleHbR);
%     close all
%     CorrelationLineGraphInterIntra(AllRoisHbR, figuretitleHbR);
%     close all
%     Graph2D(AllRoisHbR, figuretitleHbR);
%     close all
%     
%     movefile ./Figures/Histogram.png ./Figures/HbR
%     movefile ./Figures/Scatterplot.png ./Figures/HbR
%     movefile ./Figures/MedianLineGraph.png ./Figures/HbR
%     movefile ./Figures/MeanLineGraph.png ./Figures/HbR
%     movefile ./Figures/Graph2D.png ./Figures/HbR
%     
%     figuretitleHbO = strcat('HbO ', mouse);
%     HistogramInterIntra(AllRoisHbO, figuretitleHbO);
%     close all
%     CorrelationLineGraphInterIntra(AllRoisHbO, figuretitleHbO);
%     close all
%     Graph2D(AllRoisHbO, figuretitleHbO);
%     close all
%     
%     movefile ./Figures/Histogram.png ./Figures/HbO
%     movefile ./Figures/Scatterplot.png ./Figures/HbO
%     movefile ./Figures/MedianLineGraph.png ./Figures/HbO
%     movefile ./Figures/MeanLineGraph.png ./Figures/HbO
%     movefile ./Figures/Graph2D.png ./Figures/HbO
%     
%     %% Images of HbO/HbR/HbT
%     %% Average over a minute hypox vs a minute normox
%     if  contains(acquisition, 'Normoxia_1')
%         load('Mask.mat')
%     elseif ( exist([pwd filesep 'tform.mat'], 'file') )
%         load('tform.mat')
%         load('Mask.mat');
%         Mask = imwarp(Mask, tform, 'OutputView',imref2d(size(Mask)));
%     end
%     
%     %to know when the hypoxia period was
%     if( exist([pwd filesep 'Acquisition_information.txt'], 'file') )
%         fileID = fopen('Acquisition_information.txt');
%         bstop = 0;
%         while (bstop == 0) || ~feof(fileID)
%             Textline = fgetl(fileID);
%             if endsWith(Textline,'min')
%                 bstop = 1;
%             end
%         end
%         hypoxmin = str2num(Textline(1:2));
%     else
%         hypoxmin = 10;
%     end
%     
%     hypoxbegin = hypoxmin * 60 * 20;
%     hypoxend = hypoxbegin + 12000;
%     
%     hypoxminHbO = (HbO(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20))) .* Mask; %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
%     hypoxminHbR = (HbR(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20))) .* Mask; %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
%     normoxminHbO = (HbO(:,:,(5*60*20):(6*60*20))) .* Mask; %minute 5 to 6
%     normoxminHbR = (HbR(:,:,(5*60*20):(6*60*20))) .* Mask;
%     
%     % hypoxminHbO = HbO(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20)); %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
%     % hypoxminHbR = HbR(:,:,(hypoxbegin + 5*60*20):(hypoxbegin + 6*60*20)); %begin van hypoxia plus 5 min, tot begin van hypoxia plus 6 min om een minuut te krijgen midden in hypoxia periode
%     % normoxminHbO = HbO(:,:,(5*60*20):(6*60*20)); %minute 5 to 6
%     % normoxminHbR = HbR(:,:,(5*60*20):(6*60*20));
%     % hypoxminHbO = hypoxminHbO .* Mask;
%     % hypoxminHbR = hypoxminHbR .* Mask;
%     % normoxminHbO = normoxminHbO .* Mask;
%     % normoxminHbR = normoxminHbR .* Mask;
%     
%     subplot(1,2,1)
%     imagesc(mean(normoxminHbO,3),[-5 18])
% %     imagesc(mean(normoxminHbO, 3), [])
%     colorbar
%     hold on
%     imagesc(zeros(192,192,3),'AlphaData', ~Mask);
%     axis image
%     axis off
%     title('HbO Normoxia')
%     subplot(1,2,2)
%     imagesc(mean(hypoxminHbO,3), [-5 18])
%     colorbar
%     hold on
%     imagesc(zeros(192,192,3),'AlphaData', ~Mask);
%     axis image
%     axis off
%     title('HbO Hypoxia')
%     saveas(gcf, './Figures/HbONormHypox.png');
%     close all
%     
%     subplot(1,2,1)
%     imagesc(mean(normoxminHbR,3),[-5 18])
%     colorbar
%     hold on
%     imagesc(zeros(192,192,3),'AlphaData', ~Mask);
%     axis image
%     axis off
%     title('HbR Normoxia')
%     subplot(1,2,2)
%     imagesc(mean(hypoxminHbR,3), [-5 18])
%     colorbar
%     hold on
%     imagesc(zeros(192,192,3),'AlphaData', ~Mask);
%     axis image
%     axis off
%     title('HbR Hypoxia')
%     saveas(gcf, './Figures/HbRNormHypox.png');
%     close all
%     
% end

end
