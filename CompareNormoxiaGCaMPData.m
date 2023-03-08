function CompareNormoxiaGCaMPData(HypoxiaLevels, GSR)

if ~exist('GSR', 'var')
    GSR = 1;
end

% %% For graph
% %background map
% load('/media/mbakker/data1/Hypoxia/LargerAreaAtlas.mat');
% %Map gives same values for left and right, so make sure you cut into two
% Map(Map == 0) = NaN;
% %Get the right structure for names etc.
% Map(Map == 2) = 200; %Motor
% Map(Map == 3) = 300; %sensory
% Map(Map == 4) = 400; %auditory
% Map(Map == 200) = 4;
% Map(Map == 300) = 2;
% Map(Map == 400) = 3;
% Layout = Map;
% Map(:,1:464) = Map(:,1:464) + 5; %+5 because 5 ROI per side
%
% %% Centroids
% Centroids = [];
%
% for ind = 1:10 %For every ROI, get centroid to plot
%     [X, Y] = meshgrid(1:size(Map,2), 1:size(Map,1));
%
%     %Get mask from only the ROI
%     ROI = Map;
%     ROI(ROI == ind) = 100;
%     ROI(ROI < 100) = 0;
%     ROI(ROI == 100) = 1;
%     ROI(isnan(ROI)) = 0;
%
%     iX = sum(X(:).*ROI(:))/sum(ROI(:));
%     iY = sum(Y(:).*ROI(:))/sum(ROI(:));
%     iX = round(iX);
%     iY = round(iY);
%     Centroids = [Centroids; iX, iY];
% end
%
% %To exclude Auditory cortex
% Centroids = [Centroids(1:2,:); Centroids(4:7,:); Centroids(9:10,:)];
%
% clear ind iX iY ROI X Y A


% get Normoxia 1 acquitisition to compare everything to
if GSR == 1
    Norm1 = load('/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/Normoxia_1_Before.mat');
else
    Norm1 = load('/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/Normoxia_1_Before_NoGSR.mat');
end
Norm1 = reshape(Norm1.CorrBefore, 64, 7);

for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    
    if ~matches(HypoxiaLevel, 'Normoxia_1')
        %% get data
        if GSR == 1
            Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before.mat']);
        else
            Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before_NoGSR.mat']);
        end
        Name = fieldnames(Tmp);
        eval(['CorrelationValuesBefore = Tmp.' Name{:} ';']);
        CorrelationValuesBefore = reshape(CorrelationValuesBefore, 64, 7);
        
        %% Test for p-value
        
        %check for normal distribution in DIFFERENCE between correlations (paired test)
        % bla1 = reshape(Norm1, 8,8,7);
        % bla2 = reshape(CorrelationValuesBefore,8,8,7);
        % bla1 = reshape(bla1(4,1,:), 1, 7);
        % bla2 = reshape(bla2(4,1,:), 1, 7);
        % [h,p] = kstest(bla2-bla1)
        %         % not all arenormally distributed, so wilcoxon signed rank test
        
        pvalues = zeros(8);
        
        for ind = 1:64
            p = signrank(Norm1(ind,:), CorrelationValuesBefore(ind,:));
            pvalues(ind) = p;
        end
        clear ind p
        
        pvalues = tril(pvalues, -1);
        pvalues = reshape(pvalues, 64, 1);
        
        pvalues28 = [];
        for ind = 1:size(pvalues,1)
            if pvalues(ind) ~= 0
                pvalues28 = [pvalues28; pvalues(ind)];
            end
        end
        clear ind
        
        %% FDR
        qvalues = mafdr(reshape(pvalues28, [], 1),'BHFDR', 'true');
        
        q = tril(ones(8), -1);
        q = reshape(q, 64, 1);
        ind2 = 1;
        for ind = 1:64
            if q(ind) ~= 0
                q(ind) = qvalues(ind2);
                ind2 = ind2 + 1;
            end
        end
        q = reshape(q, 8, 8);
        pvalues = reshape(pvalues, 8,8);
        pqcombi = pvalues' + q;
        q(q==0) = NaN;
        pvalues(pvalues==0) = NaN;
        qvalues = q;
        
        if GSR == 1
            save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' ...
                HypoxiaLevel '_pqcombiNormCompare.mat'], 'pqcombi');
        else
            save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' ...
                HypoxiaLevel '_pqcombiNormCompare_NoGSR.mat'], 'pqcombi');
        end
        
        
    end
end
end




%             %% plot
%             %plot basis
%             imagesc(Layout, [-10 5]);
%             colormap gray
%             axis off
%             Title = [HypoxiaLevel ' Difference'];
%             title(Title);
%             % try to make it with only outside lines later, use below function?
%             % BW2 = bwmorph(BW,'remove');
%
%             threshold = 0.05;
%             threshold2 = 0.05;
%
%             CorrelationValuesBefore = reshape(mean(CorrelationValuesBefore,2,'omitnan'), 8,8);
%             CorrelationValuesHypox = reshape(mean(CorrelationValuesHypox,2,'omitnan'), 8,8);
%
%             % Plot the lines coming from ROI and going to other ROI
%             for ind = 1:8 %start with 1st ROI
%                 StartPt = Centroids(ind, :);
%                 for indC = 1:8 %correlate with 2nd ROI
%                     if (indC ~= ind) %if not correlation with itself
%
%                         V = CorrelationValuesHypox(ind, indC) - ...
%                             CorrelationValuesBefore(ind,indC); %get diff in correlation value
%
%                         %%based on significance:
%                         Q = q(ind, indC); %get corrected pvalue
%                         P = pvalues(ind, indC); %get raw pvalue
%                         EndPt = Centroids(indC, :);
%                         LW = 2; % linewidth
%
%                         if( Q < threshold ) && ( V < 0 ) % if p is below 0.05 for example and corr is negative
%                             line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
%                                 'Color','blue', 'LineWidth', LW);
%                         elseif ( Q < threshold ) && ( V > 0 ) % if sign and pos corr
%                             line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
%                                 'Color','red', 'LineWidth', LW);
%                         elseif ( P < threshold2 ) && ( V < 0 )
%                             line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
%                                 'Color','blue', 'LineStyle', '--', 'LineWidth', LW);
%                         elseif ( P < threshold2 ) && ( V > 0 )
%                             line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
%                                 'Color','red', 'LineStyle', '--', 'LineWidth', LW);
%
%                         end %of line and colour plotting
%                     end %of if not correlation with itself
%                 end %of plotting one seed with all other seeds
%             end %of plotting all seeds with all other seeds
%
%             %             saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.tiff']);
%             if GSR == 1
%                 saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.eps'], 'epsc');
%                 saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.tiff'], 'tiff');
%             else
%                 saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '_NoGSR.eps'], 'epsc');
%                 saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '_NoGSR.tiff'], 'tiff');
%             end
%             close gcf
%
%             clear ind indC V P EndPt StartPt Title
%         end %of if the condition is diff
%     end %of conditions (before, during, difference, after)
%
%
% end %of hypoxia levels
%
% end % of function
