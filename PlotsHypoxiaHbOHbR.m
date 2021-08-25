%% Scatter plots
%% Histogram for HbO/HbR
AllRoisHbR = load('AllRoisHbR.mat');
AllRoisHbR = AllRoisHbR.AllRois;

AllRoisHbO = load('AllRoisHbO.mat');
AllRoisHbO = AllRoisHbO.AllRois;

% AllRois = AllRoisHbO;
AllRois = AllRoisHbR;

IntraLim = find([AllRois{:,4}] <= 24,1,'last');
Timecourses = reshape([AllRois{:,2}],size(AllRois{1,2},2),[]);
%clip to 48000 frames
Timecourses = Timecourses(1:48000,:);

CorrMatrixBefore = corr(Timecourses(1:12000,:));
CorrMatrixHypox = corr(Timecourses(13200:24000,:));
CorrMatrixAfter = corr(Timecourses(24000:48000,:));

%%
Tmp = tril(CorrMatrixBefore,-1);
IntraLeftBefore = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterBefore = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightBefore = nonzeros(Tmp(1:IntraLim,1:IntraLim));

Tmp = tril(CorrMatrixHypox,-1);
IntraLeftHypox = nonzeros(Tmp((IntraLim+1):end,(IntraLim+1):end));
InterHypox = nonzeros(Tmp((IntraLim+1):end,1:IntraLim));
IntraRightHypox = nonzeros(Tmp(1:IntraLim,1:IntraLim));

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
title('HbO Tom')

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
