function CorrMatrix(DataFolder)

%% Correlation Matrices

CorrBefore = [];
CorrHypox = [];
CorrAfter = [];

load([DataFolder filesep 'Timecourses.mat']);

% if it's the girls 10%, correct for hypoxia timing, if its 552
% 12%, correct for problem in acquisition
if contains(DataFolder, 'Hypox_10') && contains(DataFolder, 'TheGirls')
    Timecourses = Timecourses(:,9600:end); %haal eerste 8 minuten eraf
    Timecourses(:,end+1:48000) = missing; %plak missing values aan het einde
end

if contains(DataFolder, 'Hypox_12') && contains(DataFolder, '552')
    Timecourses = Timecourses(:, 1:42000);
    Timecourses(:,end+1:48000) = missing;
end



CorrBefore = corr(Timecourses(:,3000:9000)');
CorrHypox = corr(Timecourses(:,15000:21000)');
CorrAfter = corr(Timecourses(:,39000:45000)');
CorrDiff = CorrHypox - CorrBefore;



% disp(DataFolder)
% zscores = atanh(CorrDiff); %Fisher's z transformation
% pvalues = 1 - normcdf(zscores);
% disp(pvalues(pvalues < 0.06));
% 
% zscoresBefore = atanh(CorrBefore);
% pvaluesBefore = 1 - normcdf(zscoresBefore);
% disp(pvaluesBefore(pvaluesBefore < 0.06));
% 
% zscoresHypox = atanh(CorrHypox);
% pvaluesHypox = 1 - normcdf(zscoresHypox);
% disp(pvaluesHypox(pvaluesHypox < 0.06));
% 
% zscoresAfter = atanh(CorrAfter);
% pvaluesAfter = 1 - normcdf(zscoresAfter);
% disp(pvaluesAfter(pvaluesAfter < 0.06));


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
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Before.tiff']);
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
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Hypox.tiff']);
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
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_After.tiff']);
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
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff.tiff']);
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff.fig']);
%         save(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_Diff.mat'], 'CorrDiff');
close gcf
clear index ind idx
end

%

