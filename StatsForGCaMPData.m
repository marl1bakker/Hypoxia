% CentroidType = 'Normal' or 'Max'
%
% HypoxiaLevels = {'Hypox_12', 'Hypox_10', 'Hypox_8_1', 'Hypox_8_2', ...
%     'Normoxia_1', 'Normoxia_2', 'Normoxia_3', 'Normoxia_4'};

function StatsForGCaMPData(HypoxiaLevels, Conditions, GSR)

% if ~exist('ManualInput', 'var')
%     ManualInput = 0;
% end
%
% if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/ConnectivityGraph/Normoxia_4_After.png', 'file') )
%     disp('Correlation matrices already done, exited function')
%     return;
% end
% if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/ConnectivityGraph/Normoxia_4_After.png', 'file') )
%     disp('Correlation matrices already done, OVERWRITING FILES')
% end

if ~exist('Conditions', 'var')
    Conditions = {'Before', 'Hypox', 'Diff'};
    % Conditions = {'Before', 'Hypox', 'After', 'Diff'};
end

if ~exist('GSR', 'var')
    GSR = 1;
end

%% For graph
%background map
load('/media/mbakker/data1/Hypoxia/LargerAreaAtlas.mat');
%Map gives same values for left and right, so make sure you cut into two
Map(Map == 0) = NaN;
%Get the right structure for names etc.
Map(Map == 2) = 200; %Motor
Map(Map == 3) = 300; %sensory
Map(Map == 4) = 400; %auditory
Map(Map == 200) = 4;
Map(Map == 300) = 2;
Map(Map == 400) = 3;
Layout = Map;
Map(:,1:464) = Map(:,1:464) + 5; %+5 because 5 ROI per side

%% Centroids
Centroids = [];

for ind = 1:10 %For every ROI, get centroid to plot
    [X, Y] = meshgrid(1:size(Map,2), 1:size(Map,1));
    
    %Get mask from only the ROI
    ROI = Map;
    ROI(ROI == ind) = 100;
    ROI(ROI < 100) = 0;
    ROI(ROI == 100) = 1;
    ROI(isnan(ROI)) = 0;
    
    iX = sum(X(:).*ROI(:))/sum(ROI(:));
    iY = sum(Y(:).*ROI(:))/sum(ROI(:));
    iX = round(iX);
    iY = round(iY);
    Centroids = [Centroids; iX, iY];
end

%To exclude Auditory cortex
Centroids = [Centroids(1:2,:); Centroids(4:7,:); Centroids(9:10,:)];

clear ind iX iY ROI X Y A

for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
    
    % Start making plot per condition (before hypox, during hypox or difference)
    % Everything happening here is the same hypoxia level
    
    for condition = 1:size(Conditions, 2)
        %% Stats
        % Hypoxia and Before raw correlations
        if ~matches(Conditions{condition}, 'Diff')
%             %if youre in either hypoxia or before, check raw correlation
%             %values and see if theyre sign.
%             % Get data
%             Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/' HypoxiaLevel '_' Conditions{condition} '.mat']);
%             Name = fieldnames(Tmp);
%             eval(['CorrelationValues = Tmp.' Name{:} ';']);
%             
%             zscores = atanh(CorrelationValues); %Fisher's z transformation
%             pvalues = 1 - normcdf(zscores);
%             
%             %make sure you dont run your FDR on all 64, since half is
%             %duplicates and 8 are correlation with themselves
%             pvalues28 = [];
%             pvalues = tril(pvalues, -1);
%             pvalues = reshape(pvalues, 64, 1);
%             
%             for ind = 1:size(pvalues,1)
%                 if pvalues(ind) ~= 0
%                     pvalues28 = [pvalues28; pvalues(ind)];
%                 end
%             end
%             clear ind pvalues
%                      
            %             saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.tiff']);
            if GSR == 1
                saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.eps'], 'epsc');
                saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.tiff'], 'tiff');
            else
                saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '_NoGSR.eps'], 'epsc');
                saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '_NoGSR.tiff'], 'tiff');
            end
            close gcf
            
%             %benjamini hochberg fdr
%             qvalues = mafdr(reshape(pvalues28, [], 1),'BHFDR', 'true');
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
%             
%             save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' ...
%                 HypoxiaLevel '_qvalues' Conditions{condition} '.mat'], 'q');
%             
%             %% plot
%             %plot basis
%             imagesc(Layout, [-10 5]);
%             colormap gray
%             axis off
%             Title = [HypoxiaLevel '_' Name{:}];
%             title(Title);
%             
%             threshold = 0.05;
%             threshold2 = 0.15;
%             
%             for ind = 1:8 
%                 StartPt = Centroids(ind, :);
%                 for indC = 1:8 
%                     if (indC ~= ind) 
%                         
%                         V = CorrelationValues(ind, indC);
%                         
%                         P = q(ind, indC); 
%                         EndPt = Centroids(indC, :);
%                         
%                         if( P < threshold ) && ( V < 0 ) 
%                             line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
%                                 'Color','blue', 'LineWidth', (abs(V)*3));
%                         elseif ( P < threshold ) && ( V > 0 ) 
%                             line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
%                                 'Color','red', 'LineWidth', (abs(V)*3));
%                         elseif ( P < threshold2 ) && ( V < 0 )
%                             line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
%                                 'Color','blue', 'LineStyle', '--');
%                         elseif ( P < threshold2 ) && ( V > 0 ) 
%                             line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
%                                 'Color','red', 'LineStyle', '--');
%                             
%                         end 
%                     end 
%                 end 
%             end 
%             
%             saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.tiff']);
%             close gcf
%             
%             clear ind indC V P EndPt StartPt Title
            
            
            %% Differences in correlation values
            
            %% stats
        else %if the condition is 'Diff'
            
            %bij differences, doe t-test om te kijken of ze sign. zijn
            if GSR == 1
                Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before.mat']);
            else
                Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Before_NoGSR.mat']);
            end
            Name = fieldnames(Tmp);
            eval(['CorrelationValuesBefore = Tmp.' Name{:} ';']);
            
            if GSR == 1
                Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox.mat']);
            else
                Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' HypoxiaLevel '_Hypox_NoGSR.mat']);
            end
            Name = fieldnames(Tmp);
            eval(['CorrelationValuesHypox = Tmp.' Name{:} ';']);
            clear Tmp Name
            %take certain connections:
            
            %check for normal distribution in DIFFERENCE between correlations (paired test)
            %         kstest(reshape((CorrelationValuesHypox(2,1,:) - CorrelationValuesBefore(2,1,:)), 1, 7))
            %         % not normally distributed, so wilcoxon signed rank test
            
            CorrelationValuesBefore = reshape(CorrelationValuesBefore, 64, 7);
            CorrelationValuesHypox = reshape(CorrelationValuesHypox, 64, 7);
            pvalues = zeros(8);
            
            for ind = 1:64
% Explanation here: if we test with a shapiro wilk test (swtest), we see
% mostly normal distribution, with a couple of exceptions. However, if we
% test with an kolmogorov smirnov test, we get almost all non-normal
% distributions. In the actual pvalues at the end, there are a little bit
% more significant values with a t-test, but still no significance at the
% first 8 % acquisition, and the same sort of pattern as with the wilcoxon
% signed rank test. Because wilcoxon is a bit stricter, and I want to be
% sure to get correct outcomes, I'm choosing the wilcoxon test to be safe.
                               
%                 [H, pval, ~] = swtest(CorrelationValuesHypox(ind,:) - CorrelationValuesBefore(ind,:),...
%                     0.05);
%                 if H == 1
%                     disp([num2str(pval) 'sw test for seed ' num2str(ind) ...
%                         ' at ' HypoxiaLevel]);
%                 end                
%                 [~,p] = ttest(CorrelationValuesHypox(ind,:), CorrelationValuesBefore(ind,:));

%                 kstest(CorrelationValuesHypox(ind,:) - CorrelationValuesBefore(ind,:))
                p = signrank(CorrelationValuesHypox(ind,:), CorrelationValuesBefore(ind,:));

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
            
            % all tests except the mafdr that is not BHFDR give the same
            % values. Some call output FDR, others qvalues.
            %             fdr = mafdr(reshape(pvalues28, [], 1),'BHFDR', 'true');
            %             edgar = ioi_fdr(pvalues28);
            %             [~, qvalues] = mafdr(reshape(pvalues28, [], 1));
            %             [~, qvaluespoly] = mafdr(reshape(pvalues28, [], 1), 'Method', 'polynomial');
            %             [~, crit_p, ~, qmathworks] = fdr_bh(pvalues28);
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
            
            if GSR == 1
                save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' ...
                    HypoxiaLevel '_qvaluesDiff.mat'], 'q');
                save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' ...
                    HypoxiaLevel '_pqcombi.mat'], 'pqcombi');
            else
                save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' ...
                    HypoxiaLevel '_qvaluesDiff_NoGSR.mat'], 'q');
                save(['/media/mbakker/data1/Hypoxia/CorrMatrix/ForStats/' ...
                    HypoxiaLevel '_pqcombi_NoGSR.mat'], 'pqcombi');
            end
            
            qvalues = q;
            %% plot
            %plot basis
            imagesc(Layout, [-10 5]);
            colormap gray
            axis off
            Title = [HypoxiaLevel ' Difference'];
            title(Title);
            % try to make it with only outside lines later, use below function?
            % BW2 = bwmorph(BW,'remove');
            
            threshold = 0.05;
            threshold2 = 0.05;
            
            CorrelationValuesBefore = reshape(mean(CorrelationValuesBefore,2,'omitnan'), 8,8);
            CorrelationValuesHypox = reshape(mean(CorrelationValuesHypox,2,'omitnan'), 8,8);
            
            % Plot the lines coming from ROI and going to other ROI
            for ind = 1:8 %start with 1st ROI
                StartPt = Centroids(ind, :);
                for indC = 1:8 %correlate with 2nd ROI
                    if (indC ~= ind) %if not correlation with itself
                        
                        V = CorrelationValuesHypox(ind, indC) - ...
                            CorrelationValuesBefore(ind,indC); %get diff in correlation value
                        
                        %%based on significance:
                        Q = q(ind, indC); %get corrected pvalue
                        P = pvalues(ind, indC); %get raw pvalue
                        EndPt = Centroids(indC, :);
                        LW = 2; % linewidth
                        
                        if( Q < threshold ) && ( V < 0 ) % if p is below 0.05 for example and corr is negative
                            line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
                                'Color','blue', 'LineWidth', LW);
                        elseif ( Q < threshold ) && ( V > 0 ) % if sign and pos corr
                            line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
                                'Color','red', 'LineWidth', LW);
                        elseif ( P < threshold2 ) && ( V < 0 )
                            line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
                                'Color','blue', 'LineStyle', '--', 'LineWidth', LW);
                        elseif ( P < threshold2 ) && ( V > 0 ) 
                            line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
                                'Color','red', 'LineStyle', '--', 'LineWidth', LW);
                            
                        end %of line and colour plotting
                    end %of if not correlation with itself
                end %of plotting one seed with all other seeds
            end %of plotting all seeds with all other seeds
            
            %             saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.tiff']);
            if GSR == 1
                saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.eps'], 'epsc');
                saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '.tiff'], 'tiff');
            else
                saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '_NoGSR.eps'], 'epsc');
                saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Title '_NoGSR.tiff'], 'tiff');
            end
            close gcf
            
            clear ind indC V P EndPt StartPt Title
        end %of if the condition is diff
    end %of conditions (before, during, difference, after)
    
    
end %of hypoxia levels

end % of function
