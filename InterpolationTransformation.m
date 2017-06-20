%interpolation and transform
rMin=0;
rMax=1;
Mr= 512*2;
Nr= Mr; 

for i=1:numel(werte_MaxMax)-1
    lbound = werte_MaxMax(i);
    ubound = werte_MaxMax(i+1);
    % make sure ubound and lbound are within the limits of C
    [m,n] = size(C);
    if lbound > n || ubound > n
        disp("exiting prematurely because lower or upper bound exceeds picture limits")
        break;
    end
    % make a selection on the original image to then transform its
    % coordinates
    imP= C(:,lbound:ubound);
    
    imR(1:1024,(i-1)*1024+1:i*1024)= PolarToIm (imP, rMin, rMax, Mr, Nr);

    % disp(["displaying picture from " + num2str(lbound) + " to " + num2str(ubound)])
    figure('name','in kartesischen Koordinaten')
    colormap gray;
    imagesc(imR(1:1024,(i-1)*1024+1:i*1024));
end 