%% Detects the diameter of a single bscan
% input:
% - image: C
% - borders of detected bscans: werteMaxMax 
% - the index of the bscan we should look at: bscan
% output:
% - the diameter of the 
close all;
% select one bscan using our previously detected values
bscan = 4; % the 4th scan
start = werte_MaxMax(bscan) 
finish = werte_MaxMax(bscan + 1)
Artefact2 = Artefact1(:,start:finish);
Artefact2 = imcomplement(Artefact2);
[m,n] = size(Artefact2);

colormap gray;
imagesc(Artefact2);
%Between ubound and lbound should be the oszillation
lbound = 320; %Everthing is turned black after this coordinate
ubound = 250; %Where the edge detection start
for x = 1:n %make everthing behind the pipe black & until this line the edge will be detected
    Artefact2(lbound:bildhoehe,x) = 0;
end
colormap gray;
imagesc(Artefact2);
Artefact3 = Artefact2;
MaskArtefact3 = zeros(bildhoehe,n);

for x = 1:n %fill the holes behind the pipe edge  
    for y = ubound : lbound
        if (y+100) > m
            disp("matrix limitations exceeding") % why does this happen, todo
        end
        if(Artefact3(y,x) == 1 && Artefact3(y-1,x) == 0 && Artefact3(y+100,x)== 0)
            Artefact3(y,x) = 0;
            MaskArtefact3(y,x) = 1;
        end
    end
end

BScan = Artefact3;

% S 
figure;
colormap gray;
imagesc(BScan);

BScanN = size(BScan,2);
LineEdge = zeros(BScanN,1);
Diameter = zeros(round(BScanN/2),1);

for x = 1:BScanN %Detect the edge of the pipe
    for y = 150:320
        if(BScan(y,x) == 0 && BScan(y-1,x) == 1) 
            LineEdge(x) = y;
        end
    end
end
%%
%Sometimes the pipe is not detected, use the value from above 
if(LineEdge(1) == 0)
    LineEdge(1) = LineEdge(2);
end
% drüber gucken !
% for i1 = 2:BScanN
%     if(LineEdge(i1) == 0 && LineEdge(i1+20) ~= 0)
%         LineEdge(i1) = LineEdge(i1-1);
%     end
% end

%Filtering the detected Line, if the value jumps more  than 3 pixels from
%column to another, then jump only one pixel (is probably a disturbance)
for x = 2:BScanN
    if(LineEdge(x-1) > LineEdge(x) + 3)
        LineEdge(x) = LineEdge(x-1) - 1;
    end
    if(LineEdge(x-1) < LineEdge(x) - 3)
        LineEdge(x) = LineEdge(x-1) + 1;
    end
end
figure
title('Detected Line unfiltered');
plot(1:BScanN,LineEdge);
 
%Median Filter
 ylim([0,500]);
 LineEdgeMedian = medfilt1(LineEdge,20);
 for x = 1 : 2
     LineEdgeMedian = medfilt1(LineEdgeMedian,20);
 end
 figure;
 title('Median Filter');
 plot(BScanN,LineEdgeMedian);
 ylim([0,500]);

 %Mittelwert Filter
windowSize = 30; 
b = (1/windowSize)*ones(1,windowSize);
a = 1;
for x = 1:2
    LineEdgeMedian = filter(b,a,LineEdgeMedian);
end
figure
title('Mittelwert');
 plot(1:BScanN,LineEdge);
 ylim([0,500]);
 
%Don´t use the first k filtered elements for the line
k = 100; %Maybe k is constant
LineEdge(k:BScanN) = LineEdgeMedian(k:BScanN);
figure
title('filtered Line');
plot(1:BScanN,LineEdge);
ylim([0,500]);

%Make a Matrix to convert to cartesian
Edge = zeros(512,BScanN);
LineEdge = round(LineEdge);
for x = 1:BScanN
    Edge(LineEdge(x),x) = 1;
end
%%
%Move the Picture to get real calculations
figure;
imagesc(LineEdge);
N = 512*2;
M = N;
EdgeimR = PolarToIm (Edge, 0, 1, M, N);
colormap gray;
EdgeimR = im2bw(EdgeimR, 0.4);
imagesc(EdgeimR);
%Find the highest cricle point
n = 0;
y = 100;
x = 100;
while(y < N && n == 0)
    if(EdgeimR(x,y) > 0.5 && n == 0)
        LowPoint = [x,y];
        n = n + 1;
    end
    if(y == N-1)
        y = 100;
        x = x + 1;
    end
    y = y + 1;
end
%lowest circle point
n = 0;
y = M - 100;
x = M - 100;
while(y > 1 && n == 0)
    if(EdgeimR(x,y) > 0.5 && n == 0)
        HighPoint = [x,y];
        n = n + 1;
    end
    if(y == 2)
        y = M - 100;
        x = x - 1;
    end
    y = y - 1;
end
%left circle point
n = 0;
y = 100;
x = 100;
while(x < N && n == 0)
    if(EdgeimR(x,y) > 0.5 && n == 0)
        LeftPoint = [x,y];
        n = n + 1;
    end
    if(x == N-1)
        x = 100;
        y = y + 1;
    end
    x = x + 1;
end
%right circle point
n = 0;
y = M - 100;
x = M - 100;
j2= 0;
while(x > 1 && n == 0)
    if(EdgeimR(x,y) > 0.5 && n == 0)
        RightPoint = [x,y];
        n = n + 1;
    end
    if(x == 2)
        x = M - 100;
        y = y - 1;
    end
    x = x - 1;
end

% VerticalV = HighPoint - LowPoint;
% syms t
% LineVertical = LowPoint + t * VerticalV;
% HorizontalV = RightPoint - LeftPoint;
% syms u
% LineHorizontal = LeftPoint + u * HorizontalV;
plot(HighPoint(2),HighPoint(1),'*')
plot(LowPoint(2),LowPoint(1),'*')
plot(RightPoint(2),RightPoint(1),'*')
plot(LeftPoint(2),LeftPoint(1),'*')

%Intersection of horizontal and vertical line
x = [LowPoint(1) LeftPoint(1); HighPoint(1) RightPoint(1)];  %# Starting points in first row, ending points in second row
y = [LowPoint(2) LeftPoint(2); HighPoint(2) RightPoint(2)];
dx = diff(x);  %# Take the differences down each column
dy = diff(y);
den = dx(1)*dy(2)-dy(1)*dx(2);  %# Precompute the denominator
ua = (dx(2)*(y(1)-y(3))-dy(2)*(x(1)-x(3)))/den;
ub = (dx(1)*(y(1)-y(3))-dy(1)*(x(1)-x(3)))/den;
xi = x(1)+ua*dx(1);
yi = y(1)+ua*dy(1);
xi = round(xi);
yi = round(yi);
plot(yi,xi,'r*')

% Recenter the image
drx = N/2 - xi;
dry = N/2 - yi;
EdgeimRShift = circshift(EdgeimR,drx,2);
EdgeimRShift = circshift(EdgeimRShift,dry,1);
figure;
imagesc(EdgeimRShift);
hold on;
plot(512,512,'g*')
EdgeimP = ImToPolar (EdgeimRShift, 0, 1, M/2, BScanN);
hold off;
figure;
imagesc(EdgeimP)

% Detect the Diameter
% the row in which the pipe was detected in one B-Scan + row of the edge of a B-Scan after half a rotation
% asuming that the rotation was constant during one B-Scan
for i = 1:round(BScanN/2)
    for j = 150:300 %variable which has to be set: look in which rows the pipe is detected
        if (i+(round(BScanN/2)) > size(LineEdge, 2))
            disp("exceeding matrix limitations")
        else
            Diameter(i) = LineEdge(i) + LineEdge(i+(round(BScanN/2)));
        end
    end
end

%%
RadialMin           = min(LineEdge);% to see if there is a ZERO 
RadialMax           = max(LineEdge);
DiameterMin         = min(Diameter);
DiameterMax         = max(Diameter);
DiameterEverage     = norm(Diameter)/(BScanN/2);
DiameterIntervall   = DiameterMax - DiameterMin;
DiameterDelta = 0;
for i = 1 : round(BScanN/2)
    DiameterDelta = DiameterDelta + (DiameterEverage - Diameter(i))^2;
end
DiameterError = sqrt(DiameterDelta/round(BScanN/2));