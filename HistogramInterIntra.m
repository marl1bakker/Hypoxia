function HistogramInterIntra(AllRois, Title)

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

IntraLim = find([AllRois{:,4}] <= 24,1,'last');
Timecourses = reshape([AllRois{:,2}],size(AllRois{1,2},2),[]);
Names = arrayfun(@(x) AllRois{x,3}, 1:size(AllRois,1), 'UniformOutput', false); %is for loop in principe

%clip to 48000 frames, als je er meer hebt dan 48000
if size(Timecourses,1) > 48000
    Timecourses = Timecourses(1:48000,:);
end

CorrMatrixBefore = corr(Timecourses(1:12000,:)); %first ten min, normox
CorrMatrixHypox = corr(Timecourses((hypoxbegin+1200):hypoxend,:)); %hypoxia period
CorrMatrixAfter = corr(Timecourses(36000:end,:)); %last ten min, normox

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
title(Title)
saveas(gcf, './Figures/Histogram.png');

figure()
p1 = plot(IntraLeftBefore, IntraLeftHypox, 'b.');
hold
p2 = plot(IntraRightBefore, IntraRightHypox,'r.');
p3 = plot(InterBefore, InterHypox,'color','#EDB120','Marker', '.','LineStyle', 'none');
xlim([0 1])
ylim([0 1])
line('LineWidth', 1.5);
hl = legend([p1,p2,p3],'Left', 'Right', 'Inter', 'Location','northwest')
title(Title)
saveas(gcf, './Figures/Scatterplot.png');

% 
% Namesplot = cellstr(Names);
% figure()
% scatter(IntraRightBefore, IntraRightHypox);
% dx = 0.1;
% dy = 0.1;
% text([IntraRightBefore+dx], [IntraRightHypox+dy],'bla')
% 
% text(double(IntraRightBefore+dx),double(IntraRightHypox+dy), Namesplot')
% 
% x = 1:10; y = 1:10; scatter(x,y);
% a = [1:10]'; b = num2str(a); c = cellstr(b);
% dx = 0.1; dy = 0.1; % displacement so the text does not overlay the data points
% text(x+dx, y+dy, c);
% 
% 
% 
% title('bla')




