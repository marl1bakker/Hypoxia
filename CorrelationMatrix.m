function [CMatrixWholeAcq, CMatrixBefore, CMatrixHypox, CMatrixAfter, CMatrixDiff, AllRois] ...
    = CorrelationMatrix(data, DataFolder, ROI, FigureOutput)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to make correlation matrixes, based on the correlation between 
%%% two seeds in the brain
% Input:
% data should be x y z
% bregma
% lambda
% brainmask
% Registered Allen atlas

disp(DataFolder)
if( ~strcmp(DataFolder(end), filesep) )
    DataFolder = [DataFolder filesep];
end

dims = size(data);
dd = load('mouse_ctx_borders.mat','atlas');
roi.tags = dd.atlas.areatag;

%to know when the hypoxia period was
if( exist([DataFolder filesep 'Acquisition_information.txt'], 'file') )
    fileID = fopen([DataFolder 'Acquisition_information.txt']);
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


%% Step E. Make ROI smaller, make seed timecourses and make correlation matrix
% MiddleLine = round((ROI.bregma(1) + ROI.lambda(1))/2); %midden van brein baseren op bregma en lambda
% MiddleLine = MiddleLine + (-1:1);
% BrainMask = ROI.brainmask; %brainmask heb je bij ROI_GUI getekend, wilt daarbuiten geen seeds hebben
% BrainMask(:,MiddleLine) = 0; %haal dataa van middellijn weg (wilt niet direct over bloedvat meten
% BrainMask = int8(BrainMask); 
% BrainMask(:, 1:MiddleLine(1)) = -BrainMask(:, 1:MiddleLine(1)); %maak linkerkant negatief. Links dus -1 en rechts 1. 
AtlasMask = zeros(size(data,1),size(data,2));
for ind = 1:size(ROI,2)
    AtlasMask(ROI(ind).Stats.ROI_binary_mask) = ind;
end %maak linkerkant negatief. Links dus -1 en rechts 1. 
AllRois = {};%struct('Mask',[], 'Signal',[], 'Name','', 'Index', []);
data = reshape(data,[],dims(3));
Timecourses = [];

for i = unique(nonzeros(AtlasMask(:)))' %pak alleen waarden die ook echt op de atlas staan en binnen brein vallen
    Mask = ismember(AtlasMask,i); %pak nummers van atlas van i waar je nu bent
    Tmp = bwmorph(Mask,'shrink',inf); %maak mask kleiner, noem tmp
    Tmp = conv2(Tmp, ones(3),'same')>=1; %zorg ervoor data je alleen de ROI hebt die binnen de mask vallen die je ook hebt aangegevne bij ROI_GUI
    Mask = imerode(Mask, strel('diamond',1)) & Tmp; %krimp de ROI met 1 pixel, pak alleen pixels die ook binnen tmp vallen
    if( sum(Mask(:)) >= 1 )
        Signal = mean(data(Mask(:), :),1); %pak 5 punten om midden van ROI heen, bereken timecourse van deze seed
        name = ROI(i).Name; %pak namen van ROI_GUI
        AllRois(end+1,:) = {Mask, Signal, name, find(matches(roi.tags,name))}; %voeg masker, timecourse (signaal) en naam toe aan matrix.
        Timecourses(:,end+1) = Signal;
    end
end

%Timecourses = reshape([AllRois{:,2}],dims(3),[]);

CMatrixBefore = corr(Timecourses(1:12000,:));
CMatrixHypox = corr(Timecourses((hypoxbegin+1200):hypoxend,:)); %(hypoxia period (minus one min for movement/transition)
CMatrixAfter = corr(Timecourses(36000:end,:));
CMatrixDiff = CMatrixHypox - CMatrixBefore;
CMatrixWholeAcq = corr(Timecourses);

% CMatrixBefore = zeros(size(CMatrixWholeAcq));
% CMatrixHypox = zeros(size(CMatrixWholeAcq));
% CMatrixAfter = zeros(size(CMatrixWholeAcq));
% CMatrixDiff = zeros(size(CMatrixWholeAcq));

%% Plot it
if( any(contains(FigureOutput, 'CMatrixWholeAcq')) )
    figure
    if( any(CMatrixWholeAcq(:) < -0.5) )
        imagesc(CMatrixWholeAcq,[-1,1]);
    else
        imagesc(CMatrixWholeAcq,[0,1]);
    end
    yticks(1:size(AllRois,1));
    yticklabels([AllRois(:,3)]);
    xticks(1:size(AllRois,1));
    xticklabels([AllRois(:,3)]);
    xtickangle(90)
    colormap jet
    title(strcat('Correlation Matrix Complete Period'))
end

if( any(contains(FigureOutput, 'CMatrixBefore')) )
    figure
    if( any(CMatrixBefore(:) < -0.5) )
        imagesc(CMatrixBefore,[-1,1]);
    else
        imagesc(CMatrixBefore,[0,1]);
    end
    yticks(1:size(AllRois,1));
    yticklabels([AllRois(:,3)]);
    xticks(1:size(AllRois,1));
    xticklabels([AllRois(:,3)]);
    xtickangle(90)
    colormap jet
    title(strcat('Correlation Matrix Before Hypoxia'))
    saveas(gcf, [DataFolder 'Figures/CMatrixBefore.png']);
end

if( any(contains(FigureOutput, 'CMatrixHypox')) )
    figure
    if( any(CMatrixHypox(:) < -0.5) )
        imagesc(CMatrixHypox,[-1,1]);
    else
        imagesc(CMatrixHypox,[0,1]);
    end
    yticks(1:size(AllRois,1));
    yticklabels([AllRois(:,3)]);
    xticks(1:size(AllRois,1));
    xticklabels([AllRois(:,3)]);
    xtickangle(90)
    colormap jet
    title(strcat('Correlation Matrix During Hypoxia'))
    saveas(gcf, [DataFolder 'Figures/CMatrixHypoxia.png']);
end

if( any(contains(FigureOutput, 'CMatrixAfter')) )
    figure
    if( any(CMatrixAfter(:) < -0.5) )
        imagesc(CMatrixAfter,[-1,1]);
    else
        imagesc(CMatrixAfter,[0,1]);
    end
    yticks(1:size(AllRois,1));
    yticklabels([AllRois(:,3)]);
    xticks(1:size(AllRois,1));
    xticklabels([AllRois(:,3)]);
    xtickangle(90)
    colormap jet
    title(strcat('Correlation Matrix After Hypoxia'))
    saveas(gcf, [DataFolder 'Figures/CMatrixAfter.png']);
end

if( any(contains(FigureOutput, 'CMatrixDiff')) )
    figure
    if( any(CMatrixDiff(:) < 0) )
        imagesc(CMatrixDiff,[-1,1]);
    else
        imagesc(CMatrixDiff,[0,1]);
    end
    yticks(1:size(AllRois,1));
    yticklabels([AllRois(:,3)]);
    xticks(1:size(AllRois,1));
    xticklabels([AllRois(:,3)]);
    xtickangle(90)
    colormap jet
    title(strcat('Correlation Matrix Difference Before and During Hypoxia'))
%     saveas(gcf, './Figures/CMatrixDiff.png');
end

