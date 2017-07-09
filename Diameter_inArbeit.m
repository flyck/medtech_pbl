close all;
%C_Artefact = C;
figure;
colormap gray;
imagesc(C_Artefact);
%Between ubound and lbound should be the oszillation
lbound = 320; %Everthing is turned black after this coordinate
ubound = 250; %Where the edge detection start
Artefact3 = C_Artefact(:,2100:3500);
%Artefact3 = C_Artefact(:,4150:6000);
%n = 6000-4150;
n = 3500-2100;
for x = 1:n %make everthing behind the pipe black & until this line the edge will be detected
    Artefact3(lbound:bildhoehe,x) = 0;
end
figure;
colormap gray;
imagesc(Artefact3);
MaskArtefact3 = zeros(bildhoehe,n);

for x = 1:n %fill the holes behind the pipe edge  
    for y = ubound : lbound
        if (y+100) > m
            disp('matrix limitations exceeding2') % why does this happen, todo
        end
        if(Artefact3(y,x) == 1 && Artefact3(y-1,x) == 0 && Artefact3(y+100,x)== 0)
            Artefact3(y,x) = 0;
            MaskArtefact3(y,x) = 1;
        end
    end
end

% BScan = Artefact3;

% S 
figure;
colormap gray;
imagesc(Artefact3);

BScanN = size(Artefact3,2);
LineEdge = zeros(BScanN,1);
Diameter = zeros(round(BScanN/2),1);

for x = 1:BScanN %Detect the edge of the pipe
    for y = 150:320
        if(Artefact3(y,x) == 0 && Artefact3(y-1,x) == 1) 
            LineEdge(x) = y;
        end
    end
end
%%
%Sometimes the pipe is not detected, use the value from above 
if(LineEdge(1) == 0)
    LineEdge(1) = LineEdge(2);
end
for i1 = 2:BScanN
    if(LineEdge(i1) == 0)
        LineEdge(i1) = LineEdge(i1-1);
    end
end

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
hold on;
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
%Top right
n = 0;
y = M - 100;
x = 100;
while(x < N && n == 0)
    if(EdgeimR(x,y) > 0.5 && n == 0)
        TRPoint = [x,y];
        n = n + 1;
    end
    if(x == M - y)
        x = M - y;
        y = y - 1;
    end
    x = x + 1;
end
plot(TRPoint(2),TRPoint(1),'*');
%Bottom Right
n = 0;
y = M - 100;
x = M - 100;
while(x > 1 && n == 0)
    if(EdgeimR(x,y) > 0.5 && n == 0)
        BRPoint = [x,y];
        n = n + 1;
    end
    if(x == y)
        x = y;
        y = y - 1;
    end
    x = x - 1;
end
plot(BRPoint(2),BRPoint(1),'*');
%Bottom left
n = 0;
y = 100;
x = M - 100;
while(x > 1 && n == 0)
    if(EdgeimR(x,y) > 0.5 && n == 0)
        BLPoint = [x,y];
        n = n + 1;
    end
    if(M - x ==  y)
        x = M - y;
        y = y + 1;
    end
    x = x - 1;
end
plot(BLPoint(2),BLPoint(1),'*');
%Top Left
n = 0;
y = 100;
x = 100;
while(x > 1 && n == 0)
    if(EdgeimR(x,y) > 0.5 && n == 0)
        TLPoint = [x,y];
        n = n + 1;
    end
    if(x == y)
        x = y;
        y = y + 1;
    end
    x = x + 1;
end
plot(TLPoint(2),TLPoint(1),'*');
% VerticalV = HighPoint - LowPoint;
% syms t
% LineVertical = LowPoint + t * VerticalV;
% HorizontalV = RightPoint - LeftPoint;
% syms u
% LineHorizontal = LeftPoint + u * HorizontalV;

% %Intersection of corner lines
x = [TRPoint(1) TLPoint(1); BLPoint(1) BRPoint(1)];  %# Starting points in first row, ending points in second row
y = [TRPoint(2) TLPoint(2); BLPoint(2) BRPoint(2)];
dx = diff(x);  %# Take the differences down each column
dy = diff(y);
den = dx(1)*dy(2)-dy(1)*dx(2);  %# Precompute the denominator
ua = (dx(2)*(y(1)-y(3))-dy(2)*(x(1)-x(3)))/den;
ub = (dx(1)*(y(1)-y(3))-dy(1)*(x(1)-x(3)))/den;
xi = x(1)+ua*dx(1);
yi = y(1)+ua*dy(1);
xi1 = round(xi);
yi1 = round(yi);
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
% How far away are the two intersections + take the point between them
d1 = sqrt((xi - xi1)^2+(yi - yi1)^2);
xi = (xi1 + xi)/2;
yi = (yi1 + yi)/2;

plot(HighPoint(2),HighPoint(1),'*')
plot(LowPoint(2),LowPoint(1),'*')
plot(RightPoint(2),RightPoint(1),'*')
plot(LeftPoint(2),LeftPoint(1),'*')
plot(yi,xi,'r*')
plot(yi1,xi1,'b*')
plot(512,512,'*')
figure;
% Recenter the image, only if the difference between the two detected point
% (Corner and Horizontal Intersection) is less than 100 -> if it is more ther must be something wrong 
if(d1 < 100) 
    drx = (-1) * (xi - N/2);
    dry = (-1) * (yi - N/2);
    EdgeimRShift = circshift(EdgeimR,drx,1);
    EdgeimRShift = circshift(EdgeimRShift,dry,2);
else
    EdgeimRShift = EdgeimR;
end
imagesc(EdgeimRShift);
hold on;
plot(512 + dry, 512 + drx,'*');
plot(512,512,'g*')
EdgeimP = ImToPolar (EdgeimRShift, 0, 1, M/2, BScanN);
figure;
imagesc(EdgeimP)
hold off;
% Detect the Diameter
% the row in which the pipe was detected in one B-Scan + row of the edge of a B-Scan after half a rotation
% asuming that the rotation was constant during one B-Scan
for i = 1:round(BScanN/2)
 %   for j = 150:300 %variable which has to be set: look in which rows the pipe is detected
        if (i+(round(BScanN/2)) > size(LineEdge))
             disp('exceeding matrix limitations3')
             Diameter(i) = Diameter(i-1);
         else
            Diameter(i) = LineEdge(i) + LineEdge(i+(round(BScanN/2)));
  %      end
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