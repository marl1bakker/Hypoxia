function [ImOut, TOut] = ManualCoreg(ImFixed, ImVar)
h = figure('Position', [100 100 750 550], 'CloseRequestFcn', @CloseFig);

NewIm = ImVar;
ImOut = NewIm;
TOut.Tx = 0;
TOut.Ty = 0;
TOut.Rot = 0;
TOut.Scale = 1;

ax = axes('Parent', h, 'Position', [0.2 0.2 0.75 0.75]);
imshowpair(ImFixed, ImVar, 'Parent', ax)
hsV = uicontrol('Parent', h, 'Position', [5 5 25 510], 'Style', 'slider',...
    'Min', -192, 'Max', 192, 'Value', 0, 'SliderStep',[0.001 0.005],...
    'Callback', @MoveFrame);
uicontrol('Parent', h, 'Position', [5 510 25 30], 'Style', 'text', 'String', 'Y');
hsH = uicontrol('Parent', h, 'Position', [40 5 25 510], 'Style', 'slider',...
    'Min', -192, 'Max', 192, 'Value', 0, 'SliderStep',[0.001 0.005],...
    'Callback', @MoveFrame);
uicontrol('Parent', h, 'Position', [40 510 25 30], 'Style', 'text', 'String', 'X');
hsR = uicontrol('Parent', h, 'Position', [75 5 25 510], 'Style', 'slider',...
    'Min', -pi/4, 'Max', pi/4, 'Value', 0,  'SliderStep',[0.001 0.01],...
    'Callback', @MoveFrame);
uicontrol('Parent', h, 'Position', [200 510 25 30], 'Style', 'text',...
    'String', char(hex2dec('398')));
hsS = uicontrol('Parent', h, 'Position', [110 5 25 510], 'Style', ...
    'slider', 'Min', 0, 'Max', 2, 'Value', 1,  'SliderStep',[0.001 0.01],...
    'Callback', @MoveFrame);
uicontrol('Parent', h, 'Position', [110 510 25 30], 'Style', 'text', 'String', 'S');

hDisp = uicontrol('Parent', h, 'Position', [400 20 75 50], 'Style', 'popupmenu', 'String', 'Tout|Fixe|Mobile|Alternance', 'Callback', @MoveFrame);
uicontrol('Parent', h, 'Position', [120 20 80 50], 'Style', 'text', 'String', 'Affichage:');
uicontrol('Parent', h, 'Position', [300 20 75 50], 'Style', 'pushbutton', 'String', 'Sauvegarde', 'Callback', @Save);
uicontrol('Parent', h, 'Position', [500 20 75 50], 'Style', 'pushbutton', 'String', 'Close', 'Callback', @CloseFig);


TimerObj = [];
bImShowed = 0;

MoveFrame();

waitfor(h);
    function MoveFrame(~,~,~)
        Rdefaut =  imref2d(size(ImVar));
        tX = mean(Rdefaut.XWorldLimits);
        tY = mean(Rdefaut.YWorldLimits);
        offX = hsH.Value;
        offY = hsV.Value;
        offR = hsR.Value;
        scale = hsS.Value;
        tScale = [scale, 0, 0; 0, scale, 0; 0, 0, 1];
        tTranslationToCenterAtOrigin = [1 0 0; 0 1 0; -tX -tY,1];
        tTranslationBackToOriginalCenter = [1 0 0; 0 1 0; tX tY,1];
        tRotation = [cos(offR) -sin(offR) 0; sin(offR) cos(offR) 0; 0 0 1];
        tTranslation = [1 0 0; 0 1 0; -offX -offY,1];
        tformCenteredRotation = tTranslationToCenterAtOrigin*tRotation*tTranslationBackToOriginalCenter*tTranslation*tScale;
        tformCenteredRotation = affine2d(tformCenteredRotation);
        
        NewIm = imwarp(ImVar, tformCenteredRotation, 'OutputView',imref2d(size(ImFixed)));
        
        if( ~isempty(TimerObj) )
            stop(TimerObj);
            delete(TimerObj);
            TimerObj = [];
        end
        
        switch hDisp.Value
            case 1
                imshowpair(ImFixed, NewIm, 'Parent', ax);
            case 2
                imagesc(ax, ImFixed);
                axis image;
                colormap gray;
            case 3
                imagesc(ax, NewIm);
                axis image;
                colormap gray;
            case 4
                TimerObj = timer('Period', 0.25, 'ExecutionMode', 'FixedRate', 'TimerFcn', @TimerUpdate);
                imagesc(ax, ImFixed);
                axis image;
                colormap gray;
                bImShowed = 0;
                start(TimerObj);
        end
    end

    function TimerUpdate(~,~,~)
        if( bImShowed )
            imagesc(ax, ImFixed);
            axis image;
                colormap gray;
            bImShowed = 0;
        else
            imagesc(ax, NewIm);
            axis image;
                colormap gray;
            bImShowed = 1;
        end
    end

    function CloseFig(~,~,~)
        if( ~isempty(TimerObj) )
            stop(TimerObj);
            delete(TimerObj);
        end
        TOut.Tx = hsH.Value;
        TOut.Ty = hsV.Value;
        TOut.Rot = hsR.Value;
        TOut.Scale = hsS.Value;
        
        ImOut = NewIm;
        
        delete(h);
    end

    function Save(~,~,~)
              
        RegVals.Tx = hsH.Value;
        RegVals.Ty = hsV.Value;
        RegVals.Rot = hsR.Value;
        RegVals.Scale = hsS.Value;
        
        save('Reg.mat', 'RegVals');
    end
end