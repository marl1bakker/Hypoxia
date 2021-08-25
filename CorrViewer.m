function CorrViewer(cMat,datsize)

currentPixel = [1,1];
h_fig = figure('WindowButtonDownFcn', @ChangePtPos);
h_ax = axes('Parent', h_fig);
imagesc(h_ax, reshape(cMat(1,:), datsize(1), datsize(2)), [0 1]);
axis(h_ax, 'off', 'image');
hold(h_ax, 'on');
plot(h_ax, currentPixel(1), currentPixel(2), 'or');
hold(h_ax, 'off');

    function ChangePtPos(Obj, Evnt)
        Pos = round(Obj.Children(1).CurrentPoint);
        
        Pos = Pos(1,1:2);
        if( any(Pos < 1) | any(Pos > datsize(1)) )
            return;
        end
        currentPixel = Pos;
                
        Id = floor((currentPixel(1)-1))*datsize(1) + floor(currentPixel(2));
        if( Id < 1 )
            Id = 1;
        end
        if( Id > datsize(1)*datsize(2))
            Id = datsize(1)*datsize(2);
        end
        imagesc(h_ax, reshape(cMat(:,Id), datsize(1), datsize(2)), [0 1]);
        axis(h_ax, 'off', 'image');
        hold(h_ax, 'on');
        plot(h_ax, currentPixel(1), currentPixel(2), 'or');
        hold(h_ax, 'off');
    end
end