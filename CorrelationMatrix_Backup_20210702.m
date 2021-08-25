function [CMatrixWholeAcq, CMatrixBefore, CMatrixHypox, CMatrixAfter, CMatrixDiff, AllRois] ...
    = CorrelationMatrix(data, ROI, FigureOutput)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Function to make correlation matrixes, based on the correlation between 
%%% two seeds in the brain
% Input:
% data should be x y z
% bregma
% lambda
% brainmask
% Registered Allen atlas

dims = size(data);

%% Step E. Make ROI smaller, make seed timecourses and make correlation matrix

MiddleLine = round((ROI.bregma(1) + ROI.lambda(1))/2); %midden van brein baseren op bregma en lambda
MiddleLine = MiddleLine + (-1:1);
BrainMask = ROI.brainmask; %brainmask heb je bij ROI_GUI getekend, wilt daarbuiten geen seeds hebben
BrainMask(:,MiddleLine) = 0; %haal dataa van middellijn weg (wilt niet direct over bloedvat meten
BrainMask = int8(BrainMask); 
BrainMask(:, 1:MiddleLine(1)) = -BrainMask(:, 1:MiddleLine(1));
AtlasMask = ROI.atlas_registered.*(BrainMask>0) + (24.*(ROI.atlas_registered>0) +... %geef alles wat boven 0 is de waarde 24 zodata je daarna 24 kunt optellen en niet 0 meeneemt
    ROI.atlas_registered).*(BrainMask<0); %geef juiste namen, alles negatief is links dus namen van 0 tot 24 in ROI_GUI, rechts heeft 25 tot 48
[X, Y] = meshgrid(1:dims(1),1:dims(2));
AllRois = []; %maak lege matrix voor zo in for loop

data = reshape(data,[],dims(3));

for i = unique(nonzeros(AtlasMask(:)))' %pak alleen waarden die ook echt op de atlas staan en binnen brein vallen
    Mask = ismember(AtlasMask,i); %pak nummers van atlas van i waar je nu bent
    Tmp = bwmorph(Mask,'shrink',inf); %maak mask kleiner, noem tmp
    Tmp = conv2(Tmp, ones(5),'same')>=1; %zorg ervoor data je alleen de ROI hebt die binnen de mask vallen die je ook hebt aangegevne bij ROI_GUI
    Mask = imerode(Mask, strel('diamond',1)) & Tmp; %krimp de ROI met 1 pixel, pak alleen pixels die ook binnen tmp vallen
    if( sum(Mask(:)) >= 1 )
        Signal = mean(data(Mask(:), :),1); %pak 5 punten om midden van ROI heen, bereken timecourse van deze seed
        name = ROI.tags(i); %pak namen van ROI_GUI
        AllRois = [AllRois ; Mask ,Signal, name, i]; %voeg masker, timecourse (signaal) en naam toe aan matrix.
    end
end

Timecourses = reshape([AllRois{:,2}],dims(3),[]);

CMatrixWholeAcq = corr(Timecourses);
CMatrixBefore = corr(Timecourses(1:12000,:));
CMatrixHypox = corr(Timecourses(14400:24000,:));
CMatrixAfter = corr(Timecourses(25200:end,:));
CMatrixDiff = CMatrixHypox - CMatrixBefore;


%%
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
end

if( any(contains(FigureOutput, 'CMatrixDiff')) )
    figure
    if( any(CMatrixDiff(:) < -0.1) )
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
end
