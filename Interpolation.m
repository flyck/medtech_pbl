%Versuche mit Interpolation 
%Funktion "PolarToIm" ist gut genug, es muss nicht unbedingt zurvor
%Interpoliert werden 


close all
clear all
 f=fopen('09052017034909__ascan_3.bin')
 B=fread(f,'float32');


% filename = '09052017034909__ascan_3.bin';
% filehandle = fopen(filename);
% B=fread(filehandle,'float32');


C = reshape(B,512,[]);

%Abildabschnittbreite
a=10000;
b=20000;


medfilt2_iteration_Th=3;

figure('name','Ascans')
colormap gray;
imagesc(C(:,a:b))

Vq = interp2(C(:,a:b));

%[894 2553 4414 5846 7343 9341 9535]
figure;
subplot(2,2,1);
N = 512*4;
M = N;
imR = PolarToIm (Vq(:,894*2:2553*2), 0, 1, M, N);
for i = 1:medfilt2_iteration_Th
    imR1 = medfilt2(imR,[5,5]);
end

colormap gray;
imagesc(imR);
subplot(2,2,2);
colormap gray;
imagesc(imR1);

subplot(2,2,3);
N = 512*2;
M = N;
imR2 = PolarToIm (C(:,a+894:a+2553), 0, 1, M, N);
for i = 1:medfilt2_iteration_Th
    imR22 = medfilt2(imR2,[5,5]);
end
colormap gray;
imagesc(imR22);
subplot(2,2,4);
colormap gray;
imagesc(imR2);