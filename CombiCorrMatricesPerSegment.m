%window is amoutn of minutes that you want to map in frames
% so from 10 to 20 min it will be 12000 and 10 to 30 min is 24000 

function CombiCorrMatricesPerSegment(HypoxiaLevels, Glist, SegmentSize, window, ManualInput)

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

% if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/CorrMatrix/Hypox_8_2_Before.png', 'file') )
%     disp('Correlation matrices already done, exited function')
%     return;
% end
% if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/CorrMatrix/Hypox_8_2_Before.png', 'file') )
%     disp('Correlation matrices already done, OVERWRITING FILES')
% end

%plus de twee keer want je wil ook een segment ervoor en erna
NumberOfSegments = round(window/SegmentSize);



%% Correlation Matrices
for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    
    CorrsHypoxLevel = [];
    CorrBefore = [];
    
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        
        if ~isempty(idx)
            load([Glist(ind).name filesep 'Timecourses.mat']);
            SegmentCorrsOneMouse = [];
            CorrBefore = cat(3, CorrBefore, corr(Timecourses(:,3000:9000)'));
            
            for indexy = -1:(NumberOfSegments)
                SegmentCorrs = corr(Timecourses(:, ...
                    (12000 + indexy * SegmentSize):(12000 + (indexy+1) * SegmentSize))');
                
                SegmentCorrs = reshape(SegmentCorrs, 1, 64);
                
                SegmentCorrsOneMouse = cat(1, SegmentCorrsOneMouse, SegmentCorrs);
            end
            %             CorrHypox = cat(3, CorrHypox, corr(Timecourses(:,15000:21000)'));
            CorrsHypoxLevel = cat(3, CorrsHypoxLevel, SegmentCorrsOneMouse);
        end
    end
    clear idx indexy ind
    CorrBefore = mean(CorrBefore, 3, 'omitnan');
    CorrsHypoxLevel = mean(CorrsHypoxLevel, 3, 'omitnan');
    
    figure('InvertHardcopy','off','Color',[1 1 1]);
    
    tiledlayout(2,(NumberOfSegments+2)/2)
    
    for ind = 1:size(CorrsHypoxLevel, 1)
        ax1 = nexttile;
        CorrMat = reshape(CorrsHypoxLevel(ind, :), 8,8);
        CorrMat = CorrMat - CorrBefore;
        CorrMat = tril(CorrMat);
        CorrMat(CorrMat == 0 ) = NaN;
        imagesc(ax1, CorrMat, 'AlphaData', ~isnan(CorrMat), [-0.5 0.5])
        ax1.Box = 'off';
        axis image;
        
    end    
%     for ind = 1:size(CorrsHypoxLevel, 1)
%         nexttile
%         CorrMat = reshape(CorrsHypoxLevel(ind, :), 8,8);
%         CorrMat = CorrMat - CorrBefore;
%         imagesc(CorrMat, [-0.5 0.5])
%         axis image;
%     end    
%     imagesc(CorrsHypoxLevel, [-1 1])
    %     labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    %     yticks(1:size(CorrBefore,1));
    %     yticklabels(labels);
    %     xticks(1:size(CorrBefore,2));
    %     xticklabels(labels);
    %     xtickangle(90)
    %     colorbar
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_over_time.png']);
%     save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Before.mat'], 'CorrBefore');
    close gcf
    
end

clear index ind idx

end