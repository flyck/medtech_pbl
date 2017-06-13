close all;
for i = 1:finish %make everthing behind the pipe black
    Artefact2(320:bildhoehe,i) = 0; %value is choosen manually
end
figure;
colormap gray;
imagesc(Artefact2);
Artefact3 = Artefact2;
MaskArtefact3 = zeros(bildhoehe,Artefact1n);

for i = 1:finish %fill the holes behind the pipe edge  
    for j = 200 : 320
        if(Artefact3(j,i) == 1 && Artefact3(j-1,i) == 0 && Artefact3(j+100,i)== 0)
            Artefact3(j,i) = 0;
            MaskArtefact3(j,i) = 1;
        end
    end
end

figure;
colormap gray;
imagesc(Artefact3);
BScan = Artefact3(:,3500:4825); %Just one B-Scan (determined manually)

figure;
colormap gray;
imagesc(BScan);

BScanN = size(BScan,2);
LineEdge = zeros(BScanN,1);
Diameter = zeros(BScanN/2,1);

for i = 1:BScanN %Detect the edge of the pipe
    for j = 150:300
        if(Artefact3(j,i) == 0 && Artefact3(j-1,i) == 1) 
            LineEdge(i) = j;
        end
        
    end
    
end
%Sometimes the pipe is not detected, if it is not more than 20 A-Scans in a row just 
%use the value from above ... what if it is more than 20 ???
for i = 1:BScanN
    if(i < BScanN-20 && LineEdge(i) == 0 && LineEdge(i+20) ~= 0)
        LineEdge(i) = LineEdge(i-1);
    elseif( LineEdge(i) == 0)
        LineEdge(i) = LineEdge(i-1);
    end
end

% Detect the Diameter
% the row in which the pipe was detected in one B-Scan + row of the edge of a B-Scan after half a rotation
% asuming that the rotation was constant during one B-Scan
for i = 1:BScanN/2
    for j = 150:300 %variable which has to be set: look in which rows the pipe is detected
        Diameter(i) = LineEdge(i) + LineEdge(i+(BScanN/2));
    end
end

RadialMin           = min(LineEdge);% to see if there is a ZERO 
RadialMax           = max(LineEdge);
DiameterMin         = min(Diameter);
DiameterMax         = max(Diameter);
DiameterEverage     = norm(Diameter)/(BScanN/2);
DiameterIntervall   = DiameterMax - DiameterMin;
DiameterDelta = 0;
for i = 1 : BScanN/2 
    DiameterDelta = DiameterDelta + (DiameterEverage - Diameter(i))^2;
end
DiameterError = sqrt(DiameterDelta/(BScanN/2));