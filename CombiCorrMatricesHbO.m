function CombiCorrMatricesHbO(HypoxiaLevels, Glist, ManualInput, GSR)

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if ~exist('GSR', 'var')
    GSR = 1;
end

if( ManualInput == 0 ) && GSR == 1 && ( exist('/media/mbakker/data1/Hypoxia/CorrMatrix/Hypox_8_2_Before_HbO.tiff', 'file') )
    disp('Correlation matrices already done, exited function')
    return;
elseif( ManualInput == 0 ) && GSR == 0 && ( exist('/media/mbakker/data1/Hypoxia/CorrMatrix/Hypox_8_2_Before_HbO_NoGSR.tiff', 'file') )
    disp('Correlation matrices (no GSR) already done, exited function')
    return;
end

if( ManualInput == 1 ) && GSR == 1 && ( exist('/media/mbakker/data1/Hypoxia/CorrMatrix/Hypox_8_2_Before_HbO.tiff', 'file') )
    disp('Correlation matrices already done, OVERWRITING FILES')
elseif ( ManualInput == 1 ) && GSR == 0 && ( exist('/media/mbakker/data1/Hypoxia/CorrMatrix/Hypox_8_2_Before_HbO_NoGSR.tiff', 'file') )
    disp('Correlation matrices (no GSR) already done, OVERWRITING FILES')
end

%% Correlation Matrices
for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    
    CorrBefore = [];
    CorrHypox = [];
    CorrAfter = [];
    
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, HypoxiaLevel);
        if ~isempty(idx)
            if GSR == 1
                load([Glist(ind).name filesep 'TimecoursesHbO.mat']);
            else
                load([Glist(ind).name filesep 'TimecoursesHbO_NoGSR.mat']);
            end
            
            % if it's the girls 10%, correct for hypoxia timing, if its 552
            % 12%, correct for problem in acquisition
            indhypox10 = strfind(Glist(ind).name, 'Hypox_10');
            indthegirls = strfind(Glist(ind).name, 'TheGirls');
            if ~isempty(indhypox10) && ~isempty(indthegirls)
                Timecourses = Timecourses(:,9600:end); %haal eerste 8 minuten eraf
                Timecourses(:,end+1:48000) = missing; %plak missing values aan het einde
            end
            indhypox12 = strfind(Glist(ind).name, 'Hypox_12'); %552 problem with acquisition, after 42000 has to be cut
            ind552 = strfind(Glist(ind).name, '552');
            if ~isempty(indhypox12) && ~isempty(ind552)
                Timecourses = Timecourses(:, 1:42000);
                Timecourses(:,end+1:48000) = missing;
            end
            
            indhypox82 = strfind(Glist(ind).name, 'Hypox_8_2'); 
            indTom = strfind(Glist(ind).name, 'Tom');
            if ~isempty(indhypox82) && ~isempty(indTom)
                Timecourses(:,end+1:48000) = missing;
            end
            
            CorrBefore = cat(3, CorrBefore, corr(Timecourses(:,3000:9000)'));
            CorrHypox = cat(3, CorrHypox, corr(Timecourses(:,15000:21000)'));
            CorrAfter = cat(3, CorrAfter, corr(Timecourses(:,39000:45000)'));
            
        end
    end
    
    if GSR == 1
        save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before_HbO.mat'], 'CorrBefore');
        save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox_HbO.mat'], 'CorrHypox');
    else
        save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before_HbO_NoGSR.mat'], 'CorrBefore');
        save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox_HbO_NoGSR.mat'], 'CorrHypox');
    end

    
    CorrBefore = mean(CorrBefore, 3, 'omitnan');
    CorrHypox = mean(CorrHypox, 3, 'omitnan');
    CorrAfter = mean(CorrAfter, 3, 'omitnan');
    
    CorrDiff = CorrHypox - CorrBefore;

      %% Stats
%     zscores = atanh(CorrDiff); %Fisher's z transformation
%     pvalues = 1 - normcdf(zscores);
%     pvalues = reshape(pvalues, 64, 1);
%     FDR = mafdr(pvalues, 'BHFDR', true);
%     FDR = reshape(FDR, 8,8);
%     
%     zscoresBefore = atanh(CorrBefore);
%     pvaluesBefore = 1 - normcdf(zscoresBefore);
%     pvaluesBefore = reshape(pvaluesBefore, 64, 1);
%     
%     %%Thing-gny
%     k = 1:64;
%     N = 64;
%     gamma = 0.05;
%     S = sum(1./k);    
%     
%     BH = (k/N).*(gamma/S);
%     
%     zscoresHypox = atanh(CorrHypox);
%     pvaluesHypox = 1 - normcdf(zscoresHypox);
%     pvaluesHypox = reshape(pvaluesHypox, 64, 1);
%     
%     zscoresAfter = atanh(CorrAfter);
%     pvaluesAfter = 1 - normcdf(zscoresAfter);
%     pvaluesAfter = reshape(pvaluesAfter, 64, 1);
    
    %% Corr matrix plots
    figure('InvertHardcopy','off','Color',[1 1 1]);
    ax = gca;
    data = tril(CorrBefore);
    data(data == 0 ) = NaN;
    data(data == 1 ) = NaN; %if you want to get rid of the 1's in the diagonal row
    imagesc(ax, data, 'AlphaData', ~isnan(data), [-1 1])
    ax.Box = 'off';
    axis image;
    %     imagesc(CorrBefore, [-1 1])
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    yticks(1:size(CorrBefore,1));
    yticklabels(labels);
    ay = get(gca,'YTickLabel');
    set(gca,'YTickLabel',ay,'FontSize', 20, 'FontWeight', 'bold', 'Linewidth', 2);
    xticks(1:size(CorrBefore,2));
    xticklabels(labels);
    xtickangle(90)
    load('/media/mbakker/data1/Hypoxia/SeedPixelCorrMap/NL.mat');
    colormap(NL)
    colorbar
    if GSR == 1
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Before_HbO.tiff']);
    else
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Before_HbO_NoGSR.tiff']);
    end
    %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Before.fig'])
    %     save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Before.mat'], 'CorrBefore');
    close gcf
    
    
    figure('InvertHardcopy','off','Color',[1 1 1]);
    ax = gca;
    data = tril(CorrHypox);
    data(data == 0 ) = NaN;
    data(data == 1 ) = NaN; %if you want to get rid of the 1's in the diagonal row
    imagesc(ax, data, 'AlphaData', ~isnan(data), [-1 1])
    ax.Box = 'off';
    axis image;
    %     imagesc(CorrHypox, [-1 1])
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    yticks(1:size(CorrBefore,1));
    yticklabels(labels);
    ay = get(gca,'YTickLabel');
    set(gca,'YTickLabel',ay,'FontSize', 20, 'FontWeight', 'bold', 'Linewidth', 2);
    xticks(1:size(CorrBefore,2));
    xticklabels(labels);
    xtickangle(90)
    colormap(NL)
    colorbar
    if GSR == 1
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Hypox_HbO.tiff']);
    else
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Hypox_HbO_NoGSR.tiff']);
    end
    %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Hypox.fig']);
    %         save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Hypox.mat'], 'CorrHypox');
    close gcf
    
    
    figure('InvertHardcopy','off','Color',[1 1 1]);
    ax = gca;
    data = tril(CorrAfter);
    data(data == 0 ) = NaN;
    data(data == 1 ) = NaN; %if you want to get rid of the 1's in the diagonal row
    imagesc(ax, data, 'AlphaData', ~isnan(data), [-1 1])
    ax.Box = 'off';
    axis image;
    %     imagesc(CorrAfter, [-1 1])
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    yticks(1:size(CorrBefore,1));
    yticklabels(labels);
    ay = get(gca,'YTickLabel');
    set(gca,'YTickLabel',ay,'FontSize', 20, 'FontWeight', 'bold', 'Linewidth', 2);
    xticks(1:size(CorrBefore,2));
    xticklabels(labels);
    xtickangle(90)
    colormap(NL)
    colorbar
    if GSR == 1
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_After_HbO.tiff']);
    else
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_After_HbO_NoGSR.tiff']);
    end
    %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_After.fig']);
    %      save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_After.mat'], 'CorrAfter');
    close gcf
    
    
    figure('InvertHardcopy','off','Color',[1 1 1]);
    ax = gca;
    data = tril(CorrDiff);
    data(data == 0 ) = NaN;
    data(data == 1 ) = NaN; %if you want to get rid of the 1's in the diagonal row
    imagesc(ax, data, 'AlphaData', ~isnan(data), [-0.5 0.5])
    ax.Box = 'off';
    axis image;
    %     imagesc(CorrDiff, [-0.5 0.5])
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    yticks(1:size(CorrBefore,1));
    yticklabels(labels);
    ay = get(gca,'YTickLabel');
    set(gca,'YTickLabel',ay,'FontSize', 20, 'FontWeight', 'bold', 'Linewidth', 2);
    xticks(1:size(CorrBefore,2));
    xticklabels(labels);
    xtickangle(90)
    colormap(NL)
    colorbar
    if GSR == 1
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff_HbO.tiff']);
    else
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff_HbO_NoGSR.tiff']);
    end
    %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff.fig']);
    %         save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff.mat'], 'CorrDiff');
    close gcf
    
end

clear index ind idx

end

% H82 vs N1
% load('Hypox_8_2_Hypox.mat')
% load('Normoxia_1_Before.mat')
% CorrBeforeN1 = mean(CorrBefore, 3, 'omitnan');
% CorrHypoxH82 = mean(CorrHypox, 3, 'omitnan');
% Diff = CorrHypoxH82 - CorrBeforeN1;
% Diff = tril(Diff);
% imagesc(Diff, [-0.5 0.5])
% load('/media/mbakker/data1/Hypoxia/SeedPixelCorrMap/NL.mat');
% colormap(NL)
% 
% load('Normoxia_1_Hypox.mat')
% CorrHypoxN1 = mean(CorrHypox, 3, 'omitnan');
% Diff = CorrHypoxH82 - CorrHypoxN1;
% Diff = tril(Diff);
% imagesc(Diff, [-0.5 0.5])
% colormap(NL)