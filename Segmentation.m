%------------------------ Vorverarbeitung ------------------------------%
%%
a = 30000; %Lesegrenze

file = fopen('09052017034909__ascan_3.bin'); %Öffnen der Bilddatei
imgdata = fread(file,[512,a],'float32'); %Einlesen der Datei mit float32 Eintragformatierung
mscan = reshape(imgdata,512,[]); %Umformung der Datei in eine Bildmatrix
mscan = mscan/max(mscan(:)); %Skalierung der Bildmatrix auf eine Skala 0-1

imagesc(mscan);
hold on;
figure;

%%
%------------------- Anpassbare Variablen -------------------------------%

%Für den B-Scan
s = 2247; %Startspalte
f = 3560; %Endspalte

%Für das Vorfiltern
medfiltit = 10; %Medianfilteriterationen

%Für das Filtern der einzelen A-Scans
n=10; %Medianfilteriterationen auf einem A-Scan
w=20; %Filterbreite auf einem A-Scan

%%
%------------------ Ausschneiden eines B-Scans -------------------------%

a = f-s; %horizontale Auflösung

bscanpolref = mscan(:,s:f); %Originalbild für späteren Plot

bscanpol = mscan(:,s:f); %Abgrenzung eines B-Scans

imagesc(bscanpol);
hold on;
figure;

%%
%------------------------------- Vorfiltern -----------------------------%


for k=1:medfiltit
    bscanpol = medfilt2(bscanpol,[20 3]);
end
    bscanpol = histeq(bscanpol);  
    bscanfil = bscanpol; %Gefiltertes Bild für späteren Plot

bscanpol = bscanpol(30:512,:); % Entfernung des Prismaartefakts




imagesc(bscanpol);
hold on;
figure;



%%
%----------------------------- Segmentation ----------------------------%

bordvec = (1:numel(bscanpol(1,:))); %Vektor mit den y-Werten der Kante

%% Filterung der einzelnen A-Scans > Bildung von Differentialen > Erkennung von Maximalen Steigungen > Einordnung der Maxima in den Kantenvektor
for j=1:numel(bscanpol(1,:))
v = bscanpol(:,j);

        for k=1:n
        v = medfilt1(v,w);
        end
        
v = diff(v);
[val,ind] = max(v);
bordvec(j) = ind;

end
%% Wegglätten von Artefaktbedingten Ausreissern
if bordvec(1)<150
    bordvec(1) = 150;
end

for k = 2:numel(bordvec)
    if abs((bordvec(k)-bordvec(k-1))) > 30
        bordvec(k)=bordvec(k-1);
    end
end


x = 1:numel(bordvec);
bordvec = bordvec + 30; %Korrektur der y-Werte wegen der Entfernung des Prismaartefakts

%%
imagesc(bscanpolref);
hold on;

for k = 1:numel(bordvec)
    plot(k,bordvec(k),'Linestyle','none','Marker','.','Markersize',10);
end

figure;

%% 
%--------------- Transformation in kartesische Koordinaten ---------------%

%Umwandlung des B-Scans

bscankart = PolarToIm(bscanfil,0,1,1024,1024);

imagesc(bscankart);
hold on;
figure;

%Umwandlung des Kantenvektors

bordmat = zeros(size(bscanpolref));
for k = 1:numel(bordvec)
    bordmat(1:bordvec(k),k)=1;
end


bordkart = PolarToIm(bordmat,0,1,1024,1024);

imagesc(bordkart);
hold on;


%%
%--------------------- Bestimmung des Durchmessers -----------------------%

%Kreismittelpunktbestimmung durch Tabellenverfahren

xi = 0;
yi = 0;
Ai = 0;
sumup = 0;
sumden = 0;

for k = 1:1024
    Ai = 0;
    for l = 1:1024
        if bordkart(l,k) == 1
            yi = k;
            Ai = Ai + 1;
        end
    end
    sumup = sumup + (Ai*yi);
    sumden = sumden + Ai;
end

xs = sumup/sumden;
xs = round(xs);
    
for k = 1:1024
    Ai = 0;
    for l = 1:1024
        if bordkart(k,l) == 1
            xi = k;
            Ai = Ai + 1;
        end
    end
    sumup = sumup + (Ai*xi);
    sumden = sumden + Ai;
end    

ys = sumup/sumden;
ys = round(ys);

plot(xs,ys,'Linestyle','none','Marker','.','Markersize',10);


%Bestimmung des horizontalen Durchmessers

dh = 0;

for k = 1:1024
  if bordkart(ys,k) == 1
      dh = dh+1;
  end
end

%Bestimmung des vertikalen Durchmessers

dv = 0;

for k = 1:1024
    if bordkart(k,xs) == 1
        dv = dv+1;
    end
end

d = (dh+dv)/2;

disp('Der durchschnittliche Durchmesser beträgt:')
disp(d);
