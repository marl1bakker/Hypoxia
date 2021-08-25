%% Scatter plots
%% Histogram
IntraLim = find([AllRois{:,4}] <= 24,1,'last');
Timecourses = reshape([AllRois{:,2}],size(AllRois{1,2},2),[]);
%clip to 48000 frames
Timecourses = Timecourses(1:48000,:);

CorrMatrixNorm = corr(TimecoursesNorm(13200:24000,:));
CorrMatrixHypox = corr(TimecoursesHypox(13200:24000,:));

%%

Tmp = tril(CorrMatrixHypoxMinusBefore,-1);
IntraLeft = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
Inter = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRight = nonzeros(Tmp(1:IntraLim,1:IntraLim));

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

IntraLeft = [IntraLeftBefore IntraLeftHypox IntraLeftAfter];
IntraRight = [IntraRightBefore IntraRightHypox IntraRightAfter];
Inter = [InterBefore InterHypox InterAfter];

InterDiff = InterHypox - InterBefore;
IntraDiffRight = IntraRightHypox - IntraRightBefore;
IntraDiffLeft = IntraLeftHypox - IntraLeftBefore;
IntraDiff = [IntraDiffRight(:); IntraDiffLeft(:)];

histogram(InterDiff(:),-0.5:0.015:0.5)
hold
histogram(IntraDiff, -0.5:0.015:0.5);
legend('Inter', 'Intra')
title(videoname)

%% Correlations over timecourse -- line graphs (2D graphs)
Infos = matfile('fluo_475.mat');

TC = reshape([AllRois{:,2}], Infos.datLength,[]);
Names = arrayfun(@(x) AllRois{x,3}, 1:size(AllRois,1), 'UniformOutput', false); %is for loop in principe
cPairs = repelem(Names,size(AllRois,1));
cPairs(2,:) = repmat(Names,1,size(AllRois,1));
C = zeros((Infos.datLength-1200), size(AllRois,1)*size(AllRois,1),'single');

for ind = 1:(Infos.datLength-1200)
    C(ind,:) = reshape(corr(TC((ind-1) + (1:1200),:)),[],1);
end


for ind = 1:size(cPairs, 2)
    if contains(cPairs(1,ind), '_R') && contains(cPairs(2,ind), '_R')
        cPairs(3,ind) = {'R'};
    elseif contains(cPairs(1,ind), '_L') && contains(cPairs(2,ind), '_L')
        cPairs(3,ind) = {'L'};
    else 
        cPairs(3,ind) = {'X'};
    
    end
end

idxRemove = arrayfun(@(x) matches(cPairs(1,x),cPairs(2,x)), 1:size(cPairs,2));
cPairs(:,idxRemove) = [];
C(:,idxRemove) = [];

idxR = find(contains(cPairs(3,:),{'R'}));
idxL = find(contains(cPairs(3,:),{'L'}));
idxX = find(contains(cPairs(3,:),'X'));

C = C - mean(C(1:12000, :),1);

imagesc(C(:,[idxL, idxR, idxX])')
title(videoname)

line([12000-1200, 12000-1200], [1, size(C,2)],'Color','red','LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([24000-1200, 24000-1200], [1, size(C,2)],'Color','red','LineWidth', 2,'LineStyle','--');
line([1, size(C,1)], [size(idxR,2) + size(idxL,2), size(idxR,2) + size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([1, size(C,1)], [size(idxL,2), size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':');


%%
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
title('Median Correlation between seeds - Tom HbO')

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
title('Mean Correlation between seeds - Tom HbO')

