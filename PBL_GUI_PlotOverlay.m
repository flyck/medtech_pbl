function C = PBL_GUI_PlotOverlay (C, werte_MaxMax, lbound, ubound)
    colormap gray;
    imagesc(C);
    hold on;
    [m,n] = size(C);
    % redraw the bscan values
    for i = 1 : numel(werte_MaxMax)
        if werte_MaxMax(i) < n
            plot(werte_MaxMax(i),80,'b*')
        end
    end
    %fprintf("height of %d\n", m);
    x = [lbound ubound ubound lbound];
    y = [0 0 m m];
    p = patch(x,y,'blue');
    set(p,'FaceAlpha',0.5);
    %rectangle('Position',[lbound 1 ubound m]);
end