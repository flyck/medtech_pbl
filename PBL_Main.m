%% Gruppe1 PBL - Main
% Load the measured data into the workspace.
close all;
clear all;
filename = '09052017034909__ascan_3.bin';
%filename = '09052017034420__ascan_2.bin';
filehandle = fopen(filename);
mscan = fread(filehandle,'float32');

bildhoehe = 512; % vorgegeben von Tutor

C = reshape(mscan,bildhoehe,[]);
clear mscan; % free up memory
% Scaling of values to [0,1] for compatibility with imshow / imagesc
CMAX=max(C(:));
C = C /CMAX ;

% Selection of area to work on
C = C(:,1:10000);
original = C;

colormap gray;
imagesc(C);
%%
% Convert the MScan into BScans using one of our methods: 
% Felix's method
%PBL_MScan2Bscan_Gapfinder();
% Alexandra's method
MtoBscan();
%%
% Compute and display the scans in cartesian coordinates
InterpolationTransformation();
%% 
% Filter artefacts
PBL_Filter_Artefacts();
%% 
% Interpolation and coordinate transformation
FinishedBScan = Artefact1(:,3500:4900); %todo, artefact 2 algo left out here
FinishedBScan(1:150,:) = 1;
figure; %attempt to correct the image display
imagesc(FinishedBScan);
figure;
N = 512*2;
M = N;
imR = PolarToIm (FinishedBScan, 0, 1, M, N);
imagesc(imR);