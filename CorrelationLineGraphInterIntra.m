function CorrelationLineGraphInterIntra(AllRois, Title)

%% Get right parameters
%to know when the hypoxia period was
if( exist([pwd filesep 'Acquisition_information.txt'], 'file') )
    fileID = fopen('Acquisition_information.txt');
    bstop = 0;
    while (bstop == 0) || ~feof(fileID)
        Textline = fgetl(fileID);
        if endsWith(Textline,'min')
            bstop = 1;
        end
    end
    hypoxmin = str2num(Textline(1:2));
else
    hypoxmin = 10;
end
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

C = C - mean(C(1:12000, :),1); %minus average of first 10 min (normox)



%%
plot(median(C(:,[idxR]),2))
hold on
plot(median(C(:,[idxL]),2))
plot(median(C(:,[idxX]),2))
ax = gca;
line([hypoxbegin-1200, hypoxbegin-1200], ax.YLim,'Color', 'black' ,'LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([hypoxend-1200, hypoxend-1200], ax.YLim,'Color','black','LineWidth', 2,'LineStyle','--');
legend('Right intrahemispheric correlation', 'Left intrahemispheric correlation', 'Interhemispheric correlation')
xlabel('Frames')
ylabel('Correlation')
title(Title)
subtitle('Median Correlation between seeds')
saveas(gcf, './Figures/MedianLineGraph.png');


%%
figure()
plot(mean(C(:,[idxR]),2))
hold on
plot(mean(C(:,[idxL]),2))
plot(mean(C(:,[idxX]),2))
ax = gca;
line([hypoxbegin-1200, hypoxbegin-1200], ax.YLim,'Color', 'black' ,'LineWidth', 2,'LineStyle','--'); %teken lijn voor begin en einde hypoxia, doe min 1200 omdat je correlatie over volgende minuut berekend
line([hypoxend-1200, hypoxend-1200], ax.YLim,'Color','black','LineWidth', 2,'LineStyle','--');
legend('Right intrahemispheric correlation', 'Left intrahemispheric correlation', 'Interhemispheric correlation')
xlabel('Frames')
ylabel('Correlation')
title(Title)
subtitle('Mean Correlation between seeds')
saveas(gcf, './Figures/MeanLineGraph.png');
