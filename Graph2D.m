function Graph2D(AllRois,Title)
%% Correlations over timecourse -- line graphs (2D graphs)
%to know when the hypoxia period was
fileID = fopen('Acquisition_information.txt');
bstop = 0;
while (bstop == 0) || ~feof(fileID)
   Textline = fgetl(fileID);
   if endsWith(Textline,'min')
       bstop = 1;
   end
end

hypoxmin = str2num(Textline(1:2));
hypoxbegin = hypoxmin * 60 * 20;
hypoxend = hypoxbegin + 12000;


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
title(Title)

line([hypoxbegin-1200, hypoxbegin-1200], [1, size(C,2)],'Color','red','LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([hypoxend-1200, hypoxend-1200], [1, size(C,2)],'Color','red','LineWidth', 2,'LineStyle','--');
line([1, size(C,1)], [size(idxR,2) + size(idxL,2), size(idxR,2) + size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([1, size(C,1)], [size(idxL,2), size(idxL,2)],...
    'Color','black','LineWidth', 2,'LineStyle',':');

saveas(gcf, './Figures/Graph2D.png');

