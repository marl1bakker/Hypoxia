function CombiCorrMatrices(HypoxiaLevels, Glist, ManualInput)

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/CorrMatrix/Hypox_8_2_Before.tiff', 'file') )
    disp('Correlation matrices already done, exited function')
    return;
end
if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/CorrMatrix/Hypox_8_2_Before.tiff', 'file') )
    disp('Correlation matrices already done, OVERWRITING FILES')
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
            load([Glist(ind).name filesep 'Timecourses.mat']);
            
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
            
            CorrBefore = cat(3, CorrBefore, corr(Timecourses(:,3000:9000)'));
            CorrHypox = cat(3, CorrHypox, corr(Timecourses(:,15000:21000)'));
            CorrAfter = cat(3, CorrAfter, corr(Timecourses(:,39000:45000)'));
            
        end
    end
    
    save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before.mat'], 'CorrBefore');
    save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox.mat'], 'CorrHypox');
    
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
    imagesc(ax, data, 'AlphaData', ~isnan(data), [-1 1])
    ax.Box = 'off';
    axis image;
    %     imagesc(CorrBefore, [-1 1])
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    yticks(1:size(CorrBefore,1));
    yticklabels(labels);
    xticks(1:size(CorrBefore,2));
    xticklabels(labels);
    xtickangle(90)
    colorbar
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Before.tiff']);
    %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Before.fig'])
    %     save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Before.mat'], 'CorrBefore');
    close gcf
    
    
    figure('InvertHardcopy','off','Color',[1 1 1]);
    ax = gca;
    data = tril(CorrHypox);
    data(data == 0 ) = NaN;
    imagesc(ax, data, 'AlphaData', ~isnan(data), [-1 1])
    ax.Box = 'off';
    axis image;
    %     imagesc(CorrHypox, [-1 1])
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    yticks(1:size(CorrBefore,1));
    yticklabels(labels);
    xticks(1:size(CorrBefore,2));
    xticklabels(labels);
    xtickangle(90)
    colorbar
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Hypox.tiff']);
    %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Hypox.fig']);
    %         save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Hypox.mat'], 'CorrHypox');
    close gcf
    
    
    figure('InvertHardcopy','off','Color',[1 1 1]);
    ax = gca;
    data = tril(CorrAfter);
    data(data == 0 ) = NaN;
    imagesc(ax, data, 'AlphaData', ~isnan(data), [-1 1])
    ax.Box = 'off';
    axis image;
    %     imagesc(CorrAfter, [-1 1])
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    yticks(1:size(CorrBefore,1));
    yticklabels(labels);
    xticks(1:size(CorrBefore,2));
    xticklabels(labels);
    xtickangle(90)
    colorbar
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_After.tiff']);
    %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_After.fig']);
    %      save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_After.mat'], 'CorrAfter');
    close gcf
    
    
    figure('InvertHardcopy','off','Color',[1 1 1]);
    ax = gca;
    data = tril(CorrDiff);
    data(data == 0 ) = NaN;
    imagesc(ax, data, 'AlphaData', ~isnan(data), [-0.5 0.5])
    ax.Box = 'off';
    axis image;
    %     imagesc(CorrDiff, [-0.5 0.5])
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    yticks(1:size(CorrBefore,1));
    yticklabels(labels);
    xticks(1:size(CorrBefore,2));
    xticklabels(labels);
    xtickangle(90)
    colorbar
        saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff.tiff']);
    %     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff.fig']);
    %         save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff.mat'], 'CorrDiff');
    close gcf
    
end

clear index ind idx

end