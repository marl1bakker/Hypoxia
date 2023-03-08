% Looks per seed pair at every acquisition, takes the 7 mice and does a
% friedman test over the different weeks to see if there is a difference.
% then does an FDR to see if it is still significant. If it is, we need to
% know for which weeks so we compare all the weeks to the first one.


function [pvalues, qvalues] = CompareNormoxiaFriedman(HypoxiaLevels, GSR)

if ~exist('GSR', 'var')
    GSR = 1;
end

%% Stats
%get all hypoxia levels, the correlation values per mouse
% Get CorrBefore, as made in CombiCorrMatrices. Takes frames 3000 - 9000 so
% minute 2.5 to minute 7.5
for index = 1:size(HypoxiaLevels,2)
    HypoxiaLevel = HypoxiaLevels{index};
    if GSR == 1
        eval(['C' HypoxiaLevel ' = load(["/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before.mat"]);']);
    else
        eval(['C' HypoxiaLevel ' = load(["/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before_NoGSR.mat"]);']);
    end
    eval(['C' HypoxiaLevel ' = C' HypoxiaLevel '.CorrBefore ;']);
    eval(['C' HypoxiaLevel ' = reshape(C' HypoxiaLevel ', 64, 7);']);
    eval(['C' HypoxiaLevel ' = permute(C' HypoxiaLevel ', [2 1]);']);
end

% Go per seed pair
pvalues = zeros(8);
for ind = 1:64
    
    OneSeedPair = zeros(7, size(HypoxiaLevels,2));
    
    for ind2 = 1:size(HypoxiaLevels,2)
        HypoxiaLevel = HypoxiaLevels{ind2};
        eval(['OneSeedPair(:, ind2) = C' HypoxiaLevel '(:,ind);']);
    end
    
    % take out mice with NaN values for the seed pair
    [row, ~] = find(isnan(OneSeedPair));
    OneSeedPair(row,:) = [];
    if num2str(size(OneSeedPair,1)) <= 6
        disp(['seedpair ' num2str(ind) ' has ' num2str(size(OneSeedPair,1)) ' mice for stats']);
    end
    
    % The 1 in the friedman is because we dont have any repetitions below
    % each other.
    % friedman evaluates the hypothesis that the column effects are all the
    % same against the alternative that they are not all the same. Friedman's
    % test is similar to classical balanced two-way ANOVA, but it tests only for
    % column effects after adjusting for possible row effects. It does not test
    % for row effects or interaction effects. Friedman's test is appropriate when
    % columns represent treatments that are under study, and rows represent
    % nuisance effects (blocks) that need to be taken into account but are
    % not of any interest.
    % problematic?: observations must be mutually independent.
    
    p = friedman(OneSeedPair, 1, 'off');
    pvalues(ind) = p;
%     [~, pttest] = ttest(OneSeedPair(:,4), OneSeedPair(:,5));
%     if pttest <= 0.05
%         disp(['seedpair ' num2str(ind) ' has a sign ttest p-value of ' num2str(pttest)])
%     end
    if p <= 0.05
        disp(['seedpair ' num2str(ind) ' has a sign. friedman p-value of ' num2str(p)])
    end
end

% now you have p-values for all seedpairs. Do an FDR. 
pvalues = tril(pvalues, -1);
pvalues = reshape(pvalues, 64, 1);
pvalues28 = [];
for ind = 1:size(pvalues,1)
    if pvalues(ind) ~= 0
        pvalues28 = [pvalues28; pvalues(ind)];
    end
end

pvalues(pvalues == 0) = NaN;
qvalues = mafdr(pvalues28, 'BHFDR', 'true');
q = tril(ones(8), -1);
q = reshape(q, 64, 1);
ind2 = 1;
for ind = 1:64
    if q(ind) ~= 0
        q(ind) = qvalues(ind2);
        ind2 = ind2 + 1;
    end
end
qvalues = reshape(q, 8, 8);
pvalues = reshape(pvalues, 8,8);

pqcombi = pvalues' + qvalues;

for ind = 1:64
    if q(ind) <= 0.05 && q(ind) ~= 0 
        disp(['seedpair ' num2str(ind) ' has a sign. friedman q-value of ' num2str(q(ind))])
    end
end

qvalues(qvalues == 0) = NaN;

if any(qvalues(:) < 0.05)
    % If you have a seedpair that is significantly different over the
    % hypoxia levels, find which level it is. 
    % doe kruskall
    % wallis om uit te zoeken waar dat zit. doe acq 1-2 1-3, 1-4, 1-5 etc.
    % vergelijken, en doe daar ook weer FDR overheen.
    
    signseed = find(qvalues < 0.05);
    pvalueskrusk = zeros(size(signseed,2), size(HypoxiaLevels,2));
    
    for ind = 1:size(signseed,1) %per sign. seed pair
%         disp(['Seedpair ' num2str(signseed(ind)) ' significant over hypoxia levels.']);
        for ind2 = 1:size(HypoxiaLevels,2) %check which hypox level sign.
            HypoxiaLevel = HypoxiaLevels{ind2};
            x1 = CNormoxia_1(:,signseed(ind));
            eval(['x2 = C' HypoxiaLevel '(:,signseed(ind));']);
            x = [x1,x2];
            pkrusk = kruskalwallis(x, [], 'off');
            if pkrusk < 0.05
                disp(['Seedpair ' num2str(signseed(ind)) ' is sign. at level ' ...
                    HypoxiaLevel ' with p = ' num2str(pkrusk)])
            end
            pvalueskrusk(ind, ind2) = pkrusk;
        end
    end
   
    
    qvalueskrusk = mafdr(pvalueskrusk, 'BHFDR', 'true');
    
%     if GSR == 1
%         save(['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' ...
%             HypoxiaLevel '_pqcombi.mat'], 'pqcombi');
%     else
%         save(['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' ...
%             HypoxiaLevel '_pqcombi_NoGSR.mat'], 'pqcombi');
%     end
    
end

%%NormoxiaConnectivityGraph

%% Correlation Matrices

CNormoxia_1 = mean(CNormoxia_1, 1, 'omitnan');
CNormoxia_1 = reshape(CNormoxia_1, 8,8);

for index = 1:(size(HypoxiaLevels, 2))
    HypoxiaLevel = HypoxiaLevels{index};
    if matches(HypoxiaLevel, 'Normoxia_1')
        
        %to plot:
        figure('InvertHardcopy','off','Color',[1 1 1]);
        ax = gca;
        data = tril(CNormoxia_1);
        data(data == 0 ) = NaN;
        data(data == 1 ) = NaN; %if you want to get rid of the 1's in the diagonal row
        imagesc(ax, data, 'AlphaData', ~isnan(data), [-1 1])
        ax.Box = 'off';
        axis image;
        labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
        yticks(1:size(CNormoxia_1,1));
        yticklabels(labels);
        ay = get(gca,'YTickLabel');
        set(gca,'YTickLabel',ay,'FontSize', 20, 'FontWeight', 'bold', 'Linewidth', 2);
        xticks(1:size(CNormoxia_1,2));
        xticklabels(labels);
        xtickangle(90)
        load('/media/mbakker/data1/Hypoxia/SeedPixelCorrMap/NL.mat');
        colormap(NL)
        colorbar
        if GSR == 1
            saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' HypoxiaLevel '_Normcompare.tiff']);
        else
            saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' HypoxiaLevel '_Normcompare_NoGSR.tiff']);
        end
        close gcf
        
    else
        
        eval(['Acquisition = C' HypoxiaLevel ';']);
        Acquisition = mean(Acquisition, 1, 'omitnan');
        Acquisition = reshape(Acquisition, 8,8);
        Difference = Acquisition - CNormoxia_1;
        
        %to plot:
        figure('InvertHardcopy','off','Color',[1 1 1]);
        ax = gca;
        data = tril(Difference);
        data(data == 0 ) = NaN;
        data(data == 1 ) = NaN; %if you want to get rid of the 1's in the diagonal row
        imagesc(ax, data, 'AlphaData', ~isnan(data), [-0.5 0.5])
        ax.Box = 'off';
        axis image;
        labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
        yticks(1:size(Difference,1));
        yticklabels(labels);
        ay = get(gca,'YTickLabel');
        set(gca,'YTickLabel',ay,'FontSize', 20, 'FontWeight', 'bold', 'Linewidth', 2);
        xticks(1:size(Difference,2));
        xticklabels(labels);
        xtickangle(90)
        load('/media/mbakker/data1/Hypoxia/SeedPixelCorrMap/NL.mat');
        colormap(NL)
        colorbar
        if GSR == 1
            saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' HypoxiaLevel '_Normcompare.tiff']);
        else
            saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' HypoxiaLevel '_Normcompare_NoGSR.tiff']);
        end
        close gcf
        
    end
end
end

%% Old one, CompareNormoxia.m:
% % Get baseline correlations
% CorrBaseline = [];
%
% for ind = 1:size(Glist,2)
%     idx = strfind(Glist(ind).name, Baseline);
%     if ~isempty(idx)
%         load([Glist(ind).name filesep 'Timecourses.mat']);
%         CorrBaseline = cat(3, CorrBaseline, corr(Timecourses(:, startframe:endframe)'));
%
%     end
% end
%
% NormoxiaLevels = [{Baseline}, NormoxiaLevels];
%
% for index = 1:size(NormoxiaLevels, 2)
%     NormoxiaLevel = NormoxiaLevels{index};
%     Corr = [];
%     eval(['All' NormoxiaLevel '= [];']);
%
%     for ind = 1:size(Glist,2)
%         idx = strfind(Glist(ind).name, NormoxiaLevel);
%         if ~isempty(idx) %go get timecourses per mouse
%             TimecoursesMouse = load([Glist(ind).name filesep 'Timecourses.mat']);
%             Name = fieldnames(TimecoursesMouse);
%             eval(['TimecoursesMouse = TimecoursesMouse.' Name{:} ';']);
%             %             TimecoursesMouse = TimecoursesMouse(:, startframe:endframe);
%             TimecoursesMouse = corr(TimecoursesMouse(:, startframe:endframe)');
%             eval(['All' NormoxiaLevel ' = cat(3, All' NormoxiaLevel ...
%                 ', TimecoursesMouse);']);
%         end
%     end
%
%     % kruskalwallis(
% end
% pvalues = zeros(64,1);
% for index = 1:64
%     seedpairAllLevels = [];
%     for ind = 1:size(NormoxiaLevels, 2)
%         eval(['seedpair = reshape(All' NormoxiaLevels{ind} ', 64, 7);']);
%         seedpair = seedpair(index, :);
%         seedpairAllLevels = [seedpairAllLevels; seedpair];
%     end
%     %     p = kruskalwallis(seedpairAllLevels');
%     close all
%     %     disp(['Seedpair ' num2str(index) ' pvalue = ' num2str(p)]);
%     pvalues(index) = kruskalwallis(seedpairAllLevels');
% end
%
% pvalues = reshape(pvalues, 8,8);
%
% pvalues = tril(pvalues, -1);
% pvalues = reshape(pvalues, 64, 1);
%
% pvalues28 = [];
% for ind = 1:size(pvalues,1)
%     if pvalues(ind) ~= 0
%         pvalues28 = [pvalues28; pvalues(ind)];
%     end
% end
%
%     qvalues = mafdr(reshape(pvalues28, [], 1),'BHFDR', 'true');
%
%             q = tril(ones(8), -1);
%             q = reshape(q, 64, 1);
%             ind2 = 1;
%             for ind = 1:64
%                 if q(ind) ~= 0
%                     q(ind) = qvalues(ind2);
%                     ind2 = ind2 + 1;
%                 end
%             end
%             q = reshape(q, 8, 8);
%             q(q==0) = NaN;
% qvalues = q;
% pvalues = reshape(pvalues, 8,8);
%
% %% Correlation Matrices
% %baseline
% CorrBaseline = mean(CorrBaseline, 3, 'omitnan'); %get 8 by 8 matrix of how much seeds correlate in norm 1 acquisition
%
% % get correlations of all other normoxia acquisitions
% for index = 1:size(NormoxiaLevels, 2)
%     NormoxiaLevel = NormoxiaLevels{index};
%     Corr = [];
%
%     for ind = 1:size(Glist,2)
%         idx = strfind(Glist(ind).name, NormoxiaLevel);
%         if ~isempty(idx)
%             load([Glist(ind).name filesep 'Timecourses.mat']);
%             Corr = cat(3, Corr, corr(Timecourses(:, startframe:endframe)'));
%
%         end
%     end
%
%     Corr = mean(Corr, 3, 'omitnan');
%     Corr = Corr - CorrBaseline;
%
%     %% plot
%     figure('InvertHardcopy','off','Color',[1 1 1]);
%     ax = gca;
%     data = tril(Corr);
%     data(data == 0 ) = NaN;
%     imagesc(ax, data, 'AlphaData', ~isnan(data), [-0.5 0.5])
%     ax.Box = 'off';
%     axis image;
%     labels = {'Vis R', 'Sen R', 'Mot R', 'Ret R', 'Vis L', 'Sen L', 'Mot L', 'Ret L'};
%     yticks(1:size(Corr,1));
%     yticklabels(labels);
%     ay = get(gca,'YTickLabel');
%     set(gca,'YTickLabel',ay,'FontSize', 20, 'FontWeight', 'bold', 'Linewidth', 2);
%     xticks(1:size(Corr,2));
%     xticklabels(labels);
%     xtickangle(90)
%     load('/media/mbakker/data1/Hypoxia/SeedPixelCorrMap/NL.mat');
%     colormap(NL)
%     colorbar;
%     saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' NormoxiaLevel '_NormCompare_' num2str(startframe) '-' num2str(endframe) '.tiff']);
%     save(['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' NormoxiaLevel '_NormCompare_' num2str(startframe) '-' num2str(endframe) '.mat'], 'Corr');
%     close gcf
%
%     disp(NormoxiaLevel)
%     disp(['min = ' num2str(min(Corr, [], 'all'))])
% %     max(Corr, [], 'all')
%     disp(['max = ' num2str(max(Corr, [], 'all'))])
%
% end
%
% clear index ind idx
%
% %% plot most prominent seeds (differences)
% if ~exist('Corr', 'var')
%     load(['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/Hypox_8_2_NormCompare_' num2str(startframe) '-' num2str(endframe) '.mat']);
%     %     load(['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/Normoxia_4_NormCompare_' num2str(startframe) '-' num2str(endframe) '.mat']);
% end
%
% Corr = tril(Corr); %corr is the last acquisition that you have, so 8_2, biggest change
% %find biggest changes, set threshold
% pos = find(Corr>0.09);
% neg = find(Corr<-0.09);
% posmatrix = zeros(size(NormoxiaLevels, 2), size(pos, 1));
% negmatrix = zeros(size(NormoxiaLevels, 2), size(neg, 1));
%
% for index = 1:size(NormoxiaLevels, 2)
%     NormoxiaLevel = NormoxiaLevels{index};
%     load(['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/' NormoxiaLevel '_NormCompare_' num2str(startframe) '-' num2str(endframe) '.mat']);
%     posmatrix(index,:) = Corr(pos);
%     negmatrix(index,:) = Corr(neg);
% end
%
% plot(posmatrix)
% hold on
% plot(negmatrix)
%
% saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/ChangeProminentSeeds_NormCompare_' num2str(startframe) '-' num2str(endframe) '.tiff']);
% close all
%
% %% plot most prominent seeds (raw correlation)
% %take the baseline of the seed pairs you selected, add baseline to change
% baselineposmatrix = CorrBaseline(pos)';
% baselinenegmatrix = CorrBaseline(neg)';
% posmatrix = posmatrix + baselineposmatrix; %add baseline to get raw values
% posmatrix = [baselineposmatrix; posmatrix]; %add normoxia 1
% negmatrix = negmatrix + baselinenegmatrix;
% negmatrix = [baselinenegmatrix; negmatrix];
%
% plot(posmatrix)
% hold on
% plot(negmatrix)
%
% saveas(gcf, ['/media/mbakker/data1/Hypoxia/CorrMatrix/NormCompare/AbsoluteProminentSeeds_NormCompare_' num2str(startframe) '-' num2str(endframe) '.tiff']);
% close all
%
% end