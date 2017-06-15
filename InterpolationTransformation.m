%interpolation and transform
rMin=0;
rMax=1;
Mr= 512*2;
Nr= Mr; 

for i=1:anz_Max-2
    imP= C(:,werte_MaxMax(i):werte_MaxMax(i+1));
    
    imR(1:1024,(i-1)*1024+1:i*1024)= PolarToIm (imP, rMin, rMax, Mr, Nr);

    figure('name','in kartesischen Koordinaten')
    colormap gray;
    imagesc(imR(1:1024,(i-1)*1024+1:i*1024));
end 