function CompareNormoxia(NormoxiaLevels, Baseline, Glist, ManualInput)

% startframe = 1;
% endframe = 48000;
startframe = 12000;
endframe = 24000;

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end

if( ManualInput == 0 ) && ( exist(['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/Normoxia_2_NormCompare_' num2str(startframe) '-' num2str(endframe) '.tiff'], 'file') )
    disp('Correlation matrices already done, exited function')
    return;
end
if( ManualInput == 1 ) && ( exist(['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/Normoxia_2_NormCompare_' num2str(startframe) '-' num2str(endframe) '.tiff'], 'file') )
    disp('Correlation matrices already done, OVERWRITING FILES')
end
startframe = 12000;
endframe = 24000;

%% Correlation Matrices
%% Get baseline correlations
CorrBaseline = [];

for ind = 1:size(Glist,2)
    idx = strfind(Glist(ind).name, Baseline);
    if ~isempty(idx)
        load([Glist(ind).name filesep 'Timecourses.mat']);
        CorrBaseline = cat(3, CorrBaseline, corr(Timecourses(:, startframe:endframe)'));
        
    end
end

CorrBaseline = mean(CorrBaseline, 3, 'omitnan'); %get 8 by 8 matrix of how much seeds correlate in norm 1 acquisition

%% get correlations of all other normoxia acquisitions
for index = 1:size(NormoxiaLevels, 2)
    NormoxiaLevel = NormoxiaLevels{index};
    Corr = [];
    
    for ind = 1:size(Glist,2)
        idx = strfind(Glist(ind).name, NormoxiaLevel);
        if ~isempty(idx)
            load([Glist(ind).name filesep 'Timecourses.mat']);
            Corr = cat(3, Corr, corr(Timecourses(:, startframe:endframe)'));
        
        end
    end
    
    Corr = mean(Corr, 3, 'omitnan');
    Corr = Corr - CorrBaseline;
    
    %% plot
    figure('InvertHardcopy','off','Color',[1 1 1]);
    ax = gca;
    data = tril(Corr);
    data(data == 0 ) = NaN;
    imagesc(ax, data, 'AlphaData', ~isnan(data), [-0.5 0.5])
    ax.Box = 'off';
    axis image;
    labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
    yticks(1:size(Corr,1));
    yticklabels(labels);
    xticks(1:size(Corr,2));
    xticklabels(labels);
    xtickangle(90)
    colorbar;
    saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' NormoxiaLevel '_NormCompare_' num2str(startframe) '-' num2str(endframe) '.tiff']);
    save(['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' NormoxiaLevel '_NormCompare_' num2str(startframe) '-' num2str(endframe) '.mat'], 'Corr');
    close gcf
    
    disp(NormoxiaLevel)
    min(Corr, [], 'all')
    max(Corr, [], 'all')
    
end

clear index ind idx

end