% function FuckedUpGraph(ListOfRois, data

%% Get right parameters
dd = load('mouse_ctx_borders.mat','atlas');
roi.tags = dd.atlas.areatag;
Atlas = dd.atlas.flatAtlas;
AllenMask = Atlas==0;
Atlas(:,1:464) = 24 + Atlas(:,1:464); 
Atlas(:,465)=0;
Atlas(AllenMask) = 0;
RP = regionprops(Atlas, 'Centroid');

CentroMap = zeros(size(Atlas));
Centroids = round(reshape([RP(:).Centroid],2,[]));
idx = sub2ind(size(Atlas),Centroids(2,:), Centroids(1,:));
CentroMap(idx) = 1;

map = [1 1 1; 0 0 0];


%% Fucked-up graph -- only Barrel Cortex
RightBarrelcortexindex = find(contains(AllRois(:,3),'BC_R')); %find index nummer van rechter barrel cortex, is 6
LeftBarrelcortexindex = find(contains(AllRois(:,3),'BC_L')); %ditto links, is 26 (omdat er een paar regios niet binnen ons masker vallen en dus geen correlatie hebben)
RightBarrelcortexAllenvalue = AllRois{RightBarrelcortexindex,4}; %actual number of the region, still 6
LeftBarrelcortexAllenvalue = AllRois{LeftBarrelcortexindex,4}; %ditto, 30
PointsDepart = [RightBarrelcortexAllenvalue, LeftBarrelcortexAllenvalue]; %is [6,30]
imagesc(dd.atlas.borders);
hold
colormap(map)
hold;
AreasUsed = [AllRois{:,4}]; %pak echte waarden van regios die gebruikt zijn
    
ValeursCorrelations = CorrMatrixHypoxMinusBefore([RightBarrelcortexindex, LeftBarrelcortexindex],:); %pak van correlation matrix alle correlatie waarden van barrel cortexen
for ind = 1:size(ValeursCorrelations,1) %for 1:2
   
    StartPt = Centroids(:,PointsDepart(ind)); %startpoint is centroid van regio, dus [6,30] van eerste of tweede BC
    for indC = 1:size(ValeursCorrelations,2) %for 1:39
        AllenValue = AllRois{indC,4};
        if( (AllenValue ~= PointsDepart(ind))  ) %if not correlation with itself ...
            V = ValeursCorrelations(ind, indC); %get correlation value 
            if( V < 0 )
                line([StartPt(1), Centroids(1,AllenValue)], [StartPt(2), Centroids(2,AllenValue)],...
                    'Color',[0.875 0.5+V 0.5+V], 'LineWidth', 2.5);
                %                     'Color','blue', 'LineWidth', LineWdthEq(abs(V)));
            elseif( V > 0 )
                line([StartPt(1), Centroids(1,AllenValue)], [StartPt(2), Centroids(2,AllenValue)],...
                    'Color',[0.5-V 0.875 0.5-V], 'LineWidth', 2.5);
                    
            end
        end
        
    end
    axis image
end
viscircles(Centroids', 5*ones(48,1))


%% Fucked-up Graph - Map Difference hypox and befor
imagesc(dd.atlas.borders);
colormap(map)
hold;
% LineWdthEq = @(c) 0.01 + (5-0.01)*((c - min(abs(CorrMatrixHypoxia(:))))/(max(abs(CorrMatrixHypoxia(:))) - min(abs(CorrMatrixHypoxia(:)))));
AreasUsed = [AllRois{:,4}];
Tmp = tril(CorrMatrixHypoxMinusBefore,-1); %geeft lower triangular matrix 

for ind = 1:size(Centroids,2)
    StartPt = Centroids(:,ind);
    iX = find(ind == AreasUsed, 1, 'first');
    for indC = 1:size(Centroids,2)
        if( (indC ~= ind) & all(ismember([ind, indC],AreasUsed)) )
            iY = find(indC == AreasUsed, 1, 'first');
            V = Tmp(iY, iX);
            if( V < -0.3 )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue','LineWidth', 2);
%                     'Color','blue', 'LineWidth', LineWdthEq(abs(V)));
            elseif( V > 0.3 )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red','LineWidth', 2);
            elseif( V < -0.2 && V > -0.5)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue', 'LineStyle',':','LineWidth', 2);
            elseif( V > 0.2 && V < 0.5)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red', 'LineStyle',':','LineWidth', 2);
            end
        end
    end
end
viscircles(Centroids', 5*ones(48,1))
plot(dd.atlas.borders,'w');
axis off
title('Correlation ROI ')
%imagesc(conv2(CentroMap, ones(5), 'same'))


%% scatter plot of inter-intra hemispheric connectivity
IntraLim = find([AllRois{:,4}] <= 24,1,'last');
Tmp = tril(CorrMatrixHypoxMinusBefore,-1);
IntraLeft = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
Inter = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRight = nonzeros(Tmp(1:IntraLim,1:IntraLim));

% boxplot([IntraLeft; IntraRight; Inter],...
%     [ones(size(IntraLeft)); 2*ones(size(IntraRight)); 3*ones(size(Inter))]);

Tmp = tril(CorrMatrixHypox,-1);
IntraLeftHypox = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterHypox = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightHypox = nonzeros(Tmp(1:IntraLim,1:IntraLim));

Tmp = tril(CorrMatrixBefore,-1);
IntraLeftBefore = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterBefore = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightBefore = nonzeros(Tmp(1:IntraLim,1:IntraLim));

Tmp = tril(CorrMatrixAfter,-1);
IntraLeftAfter = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterAfter = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightAfter = nonzeros(Tmp(1:IntraLim,1:IntraLim));

% boxplot([IntraLeftBefore; IntraLeftHypox; IntraLeftAfter; IntraRightBefore; IntraRightHypox; IntraRightAfter; InterBefore; InterHypox; InterAfter],...
%     [0.75*ones(size(IntraLeft));ones(size(IntraLeft));1.25*ones(size(IntraLeft)); 1.75*ones(size(IntraRight));2*ones(size(IntraRight));2.25*ones(size(IntraRight)); 2.75*ones(size(Inter));3*ones(size(Inter));3.25*ones(size(Inter))],...
%     'Labels',{'Before Hypoxia','During Hypoxia','After Hypoxia','Before Hypoxia','During Hypoxia','After Hypoxia','Before Hypoxia','During Hypoxia','After Hypoxia'});
% 
% boxplot([IntraLeftBefore; IntraRightBefore;InterBefore;IntraLeftHypox;IntraRightHypox;InterHypox; IntraLeftAfter;   IntraRightAfter;   InterAfter],...
%     [0.75*ones(size(IntraLeft));ones(size(IntraLeft));1.25*ones(size(IntraLeft)); 1.75*ones(size(IntraRight));2*ones(size(IntraRight));2.25*ones(size(IntraRight)); 2.75*ones(size(Inter));3*ones(size(Inter));3.25*ones(size(Inter))],...
%     'Labels',{'','Before Hypoxia','','','During Hypoxia','','','After Hypoxia',''});


%   boxplotGroup(x) receives a 1xm cell array where each element is a matrix with
%   n columns and produces n groups of boxplot boxes with m boxes per group.
IntraLeft = [IntraLeftBefore IntraLeftHypox IntraLeftAfter];
IntraRight = [IntraRightBefore IntraRightHypox IntraRightAfter];
Inter = [InterBefore InterHypox InterAfter];
GroupedBoxplots = {IntraLeft, IntraRight, Inter}
% ticklabels: before: left right inter ... during: left right inter ...
% after: left right inter

boxplotGroup(GroupedBoxplots,'primarylabels',{'R','L','X'}, ...
    'secondarylabels',{'Before','Hypoxia','After'});

%%
plot(median(C(:,[idxR]),2))
hold
plot(median(C(:,[idxL]),2))
plot(median(C(:,[idxX]),2))
line([12000-1200, 12000-1200], [-0.15, 0.15],'Color', 'black' ,'LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([24000-1200, 24000-1200], [-0.15, 0.15],'Color','black','LineWidth', 2,'LineStyle','--');
legend('Right intrahemispheric correlation', 'Left intrahemispheric correlation', 'Interhemispheric correlation')
xlabel('Frames')
ylabel('Correlation')
title('Median Correlation between seeds - Tom (without GSR)')

%%
plot(mean(C(:,[idxR]),2))
hold
plot(mean(C(:,[idxL]),2))
plot(mean(C(:,[idxX]),2))
line([12000-1200, 12000-1200], [-0.15, 0.15],'Color', 'black' ,'LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([24000-1200, 24000-1200], [-0.15, 0.15],'Color','black','LineWidth', 2,'LineStyle','--');
legend('Right intrahemispheric correlation', 'Left intrahemispheric correlation', 'Interhemispheric correlation')
xlabel('Frames')
ylabel('Correlation')
title('Mean Correlation between seeds - Tom (without GSR)')

%% ------------------------------------------------------------------------
% ThresholdDotted = 0.7;
% ThresholdLine = 0.8;
ThresholdDotted = 0.4;
ThresholdLine = 0.5;

% Before hypoxia
imagesc(dd.atlas.borders);
colormap(map)
hold;
AreasUsed = [AllRois{:,4}];
Tmp = tril(CorrMatrixBefore,-1); %geeft lower triangular matrix 

for ind = 1:size(Centroids,2)
    StartPt = Centroids(:,ind);
    iX = find(ind == AreasUsed, 1, 'first');
    for indC = 1:size(Centroids,2)
        if( (indC ~= ind) & all(ismember([ind, indC],AreasUsed)) )
            iY = find(indC == AreasUsed, 1, 'first');
            V = Tmp(iY, iX);
            if( V < -ThresholdLine )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue');
            elseif( V > ThresholdLine )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red');
            elseif( V < -ThresholdDotted && V > -ThresholdLine)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue', 'LineStyle',':');
            elseif( V > ThresholdDotted && V < ThresholdLine)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red', 'LineStyle',':');
            end
        end
    end
end
viscircles(Centroids', 5*ones(48,1))
plot(dd.atlas.borders,'w');
axis off
title('Correlation ROI before Hypoxia')

%%
% During hypoxia
figure;
imagesc(dd.atlas.borders);
% colormap gray
colormap(map)
hold;
% LineWdthEq = @(c) 0.01 + (5-0.01)*((c - min(abs(CorrMatrixHypoxia(:))))/(max(abs(CorrMatrixHypoxia(:))) - min(abs(CorrMatrixHypoxia(:)))));
AreasUsed = [AllRois{:,4}];
Tmp = tril(CorrMatrixHypox,-1); %geeft lower triangular matrix 

for ind = 1:size(Centroids,2)
    StartPt = Centroids(:,ind);
    iX = find(ind == AreasUsed, 1, 'first');
    for indC = 1:size(Centroids,2)
        if( (indC ~= ind) & all(ismember([ind, indC],AreasUsed)) )
            iY = find(indC == AreasUsed, 1, 'first');
            V = Tmp(iY, iX);
            if( V < -ThresholdLine )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue');
            elseif( V > ThresholdLine )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red');
            elseif( V < -ThresholdDotted && V > -ThresholdLine)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue', 'LineStyle',':');
            elseif( V > ThresholdDotted && V < ThresholdLine)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red', 'LineStyle',':');
            end
        end
    end
end
viscircles(Centroids', 5*ones(48,1))
plot(dd.atlas.borders,'w');
axis off
title('Correlation ROI during Hypoxia')
%imagesc(conv2(CentroMap, ones(5), 'same'))

% After hypoxia
figure;
imagesc(dd.atlas.borders);
colormap(map)
hold;
AreasUsed = [AllRois{:,4}];
Tmp = tril(CorrMatrixAfter,-1); %geeft lower triangular matrix 

for ind = 1:size(Centroids,2)
    StartPt = Centroids(:,ind);
    iX = find(ind == AreasUsed, 1, 'first');
    for indC = 1:size(Centroids,2)
        if( (indC ~= ind) & all(ismember([ind, indC],AreasUsed)) )
            iY = find(indC == AreasUsed, 1, 'first');
            V = Tmp(iY, iX);
            if( V < -ThresholdLine )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue');
            elseif( V > ThresholdLine )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red');
            elseif( V < -ThresholdDotted && V > -ThresholdLine)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue', 'LineStyle',':');
            elseif( V > ThresholdDotted && V < ThresholdLine)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red', 'LineStyle',':');
            end
        end
    end
end
viscircles(Centroids', 5*ones(48,1))
plot(dd.atlas.borders,'w');
axis off
title('Correlation ROI after Hypoxia')


% difference hypoxia and before
ThresholdDottedDiff = 0.25;
ThresholdLineDiff = 0.3;

figure;
imagesc(dd.atlas.borders);
colormap(map)
hold;
AreasUsed = [AllRois{:,4}];
Tmp = tril(CorrMatrixHypoxMinusBefore,-1); %geeft lower triangular matrix 

for ind = 1:size(Centroids,2)
    StartPt = Centroids(:,ind);
    iX = find(ind == AreasUsed, 1, 'first');
    for indC = 1:size(Centroids,2)
        if( (indC ~= ind) & all(ismember([ind, indC],AreasUsed)) )
            iY = find(indC == AreasUsed, 1, 'first');
            V = Tmp(iY, iX);
            if( V < -ThresholdLineDiff )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue');
            elseif( V > ThresholdLineDiff )
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red');
            elseif( V < -ThresholdDottedDiff && V > -ThresholdLineDiff)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','blue', 'LineStyle',':');
            elseif( V > ThresholdDottedDiff && V < ThresholdLineDiff)
                line([StartPt(1), Centroids(1,indC)], [StartPt(2), Centroids(2,indC)],...
                    'Color','red', 'LineStyle',':');
            end
        end
    end
end
viscircles(Centroids', 5*ones(48,1))
plot(dd.atlas.borders,'w');
axis off
title('Correlation Difference before hypoxia - hypoxia')