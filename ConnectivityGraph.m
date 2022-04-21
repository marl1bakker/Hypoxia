%% This is made for BigROI.mat!

function ConnectivityGraph(HypoxiaLevels, Mouse, ManualInput)

if ~exist('ManualInput', 'var')
    ManualInput = 0;
end
% 
% if( ManualInput == 0 ) && ( exist('/media/mbakker/data1/Hypoxia/ConnectivityGraph/Normoxia_4_After.png', 'file') )
%     disp('Correlation matrices already done, exited function')
%     return;
% end
% if( ManualInput == 1 ) && ( exist('/media/mbakker/data1/Hypoxia/ConnectivityGraph/Normoxia_4_After.png', 'file') )
%     disp('Correlation matrices already done, OVERWRITING FILES')
% end


%% Fucked Up Graph Generation
for index = 1:size(HypoxiaLevels, 2)
    HypoxiaLevel = HypoxiaLevels{index};
%     disp(HypoxiaLevel)

    %% Centroids
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
    
    Centroids = [];
    %GetCentroid
    for ind = 1:10 %For every ROI, get centroid to plot
        [X, Y] = meshgrid(1:951, 1:900);
        
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
        %expand slightly
        %         Seed = zeros(951, 900);
        %         Seed(iY, iX) = 1;
        %         Seed = conv2(Seed, fspecial('disk',3)>0,'same')>0;
        Centroids = [Centroids; iX, iY];
    end
    
    %To exclude Auditory cortex
    Centroids = [Centroids(1:2,:); Centroids(4:7,:); Centroids(9:10,:)];
    
    clear ind iX iY ROI X Y
    
    
    
    %% Start making plot per condition (before hypox, during hypox or difference)
    % Everything happening here is still the same hypoxia level
    Conditions = {'Before', 'Hypox', 'Diff'};
    % Conditions = {'Before', 'Hypox', 'After', 'Diff'};
    
    for condition = 1:size(Conditions, 2)
        % Get data
        Tmp = load(['/media/mbakker/data1/Hypoxia/CorrMatrix/' Mouse filesep HypoxiaLevel '_' Conditions{condition} '.mat']);  
        Name = fieldnames(Tmp);
        eval(['CorrelationValues = Tmp.' Name{:} ';']);
        
        if matches(Conditions{condition}, 'Diff') 
            threshold = 0.15; %threshold for difference depicted in the graph
        else
            threshold = 0.3; %theshold direct corr. depicted in graph
        end    
            
        %plot basis
        imagesc(Layout, [-10 5]);
        colormap gray
        axis off
        Title = [HypoxiaLevel '_' Name{:}];
        title(Title);
        % try to make it with only outside lines later, use below function?
        % BW2 = bwmorph(BW,'remove');
        
        
        % Plot the lines coming from ROI and going to other ROI
        for ind = 1:size(CorrelationValues,1) %start with 1st ROI
            StartPt = Centroids(ind, :);
            for indC = 1:size(CorrelationValues,2) %correlate with 2nd ROI
                if (indC ~= ind) %if not correlation with itself
                    V = CorrelationValues(ind, indC); %get correlation value
                    EndPt = Centroids(indC, :);
                    if( V < -threshold ) %if negative corr crossing threshold
                        line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
                            'Color','blue', 'LineWidth', (abs(V)*3));
%                             'Color', [62 38 168]./255, 'LineWidth', (abs(V)*3));
                        %   'Color','blue', 'LineWidth', (abs(V)*3));
                    elseif( V > threshold ) %if pos corr
                        line([StartPt(1), EndPt(1)], [StartPt(2), EndPt(2)],...
                            'Color','red', 'LineWidth', (abs(V)*3));
%                             'Color',[249 251 20]./255, 'LineWidth', (abs(V)*3));
                    end
                end
                
            end %of plotting 1 line
        end %of all correlations of 1 centroid
        % viscircles(Centroids', 5*ones(48,1))

    saveas(gcf, ['/media/mbakker/data1/Hypoxia/ConnectivityGraph/' Mouse filesep Title '.tiff']);
    close gcf     
        
    end %of conditions (before, during, difference, after)
    
end %of hypoxia levels



end

