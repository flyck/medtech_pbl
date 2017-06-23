%%Preprocessing 

%%noch sehr unübersichtlich

%Sensor Offset 
clearvars -except Offset Chirp
close all

filename = '09052017034909__raw_3.bin';
%filename = '09052017034420__ascan_2.bin';
filehandle = fopen(filename);
bildhoehe = 1024; 
a=100; %number of the Ascan 
raw = fread(filehandle,[1024,10000],'uint16');
raw1=raw*540;



MOffset=zeros(1024,10000);
for i=1:10000
MOffset(:,i)=Offset;
end 

Mraw=raw-MOffset;


plot(1:1024,Mraw(:,a))


%detect DC
p=polyfit([1:1024]',Mraw(:,a),10);
y2 = polyval(p,1:1024);

figure
plot(1:1024,y2)

%remove DC
D=Mraw(:,a)-y2';
figure
plot(1:1024,D)


%Window Function (Hann)
w=hann(1024);
figure
plot(1:1024,w)


%Intensity times Hann 
Raw=D.*w;
figure
plot(1:1024,Raw);


%Fourier Transform
F=fft(Raw);
BF=abs(F);
%Übung:  Zur Darstellung üblicherweise logarithmische Kompression 20*ln(X)
BF1=20*log(BF);
%half of the signal 
BF2=BF1(1:512);

imagesc(BF2)