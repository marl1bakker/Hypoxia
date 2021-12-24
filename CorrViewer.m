function CorrViewer(cMat, datsize, Map)

currentPixel = [1,1];
h_fig = figure('WindowButtonDownFcn', @ChangePtPos);
h_ax = axes('Parent', h_fig);
Im = zeros(192);
Im(Map) = cMat(1,:);
imagesc(h_ax, Im, [-0.5 0.5]);
axis(h_ax, 'off', 'image');
hold(h_ax, 'on');
plot(h_ax, currentPixel(1), currentPixel(2), 'or');
hold(h_ax, 'off');
Mapidx = find(Map);

    function ChangePtPos(Obj, Evnt)
        Pos = round(Obj.Children(1).CurrentPoint);
        
        Pos = Pos(1,1:2);
        idx = sub2ind([192,192],Pos(2),Pos(1));
        if( any(Pos < 1) | any(Pos > datsize(1)) | ~any(ismember(Mapidx, idx)) )
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
        Im(Map) = cMat(:, find(Mapidx == idx));
        imagesc(h_ax, Im, [-0.5 0.5]);
        axis(h_ax, 'off', 'image');
        hold(h_ax, 'on');
        plot(h_ax, currentPixel(1), currentPixel(2), 'or');
        hold(h_ax, 'off');
    end
end