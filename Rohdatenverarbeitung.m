%% Preprocessing 
% clearvars -except Offset Chirp
% close all

% %filename = '09052017034909__raw_3.bin';
% filename = '09052017034420__raw_2.bin';
% filehandle = fopen(filename);

 bildhoehe = 1024; 
a=10000; %number of the Ascan 

raw = fread(filehandle,[1024,a],'uint16');
fclose(filehandle)
raw=raw*540;


%% Sensor Offset (Dunkelstrom)

MOffset=zeros(1024,a);
for i=1:a
MOffset(:,i)=Offset;
end

%remove offset
Mraw=raw-MOffset;

    %example of one ascan
    figure('name','Dunkelstrom entfernt')
    plot(1:1024,Mraw(:,a))


%% detect and remove DC
%mean value of each row of Mraw 
dc=zeros(1024,1);
for i=1:1024
dc(i,1)=mean(Mraw(i,:));
end 

DC=zeros(1024,a);
for i=1:a
DC(:,i)=dc;
end 

%remove DC
rawDC=Mraw(:,1:a)-DC;

    %example for one ascan
    figure('name','DC removed')
    plot(1:1024,rawDC(:,1))
%% Apodisation
%Window Function (Hann)
w=hann(1024);
figure('name','Hann window')
plot(1:1024,w)

%Intensity times Hann 
rawW=rawDC.*w*500;


%% Dechirp
% interpolation at chirp query points 
DChirp=interp1(Chirp,rawW,0:1023);

    %example for one ascan
    figure('name','Adiposation with Hann window')
    plot(1:1024,DChirp(:,1));


%% Fourier Transform

rawF=fft(DChirp);

BF=abs(rawF);
%Übung:  Zur Darstellung üblicherweise logarithmische Kompression 20*ln(X)
BF1=20*log(BF);
%half of the signal 
BF2=BF1(1:512,:);


figure('name','Mscan')
colormap gray;
imagesc(BF2)
