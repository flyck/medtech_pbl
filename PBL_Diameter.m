function [DiameterMin, DiameterMax,DiameterEverage] = PBL_Filter_Artefacts(C_Artefact, C)
    %colormap gray;
    %imagesc(C_Artefact);
    %Between ubound and lbound should be the oszillation
    lbound = 320; %Everthing is turned black after this coordinate
    ubound = 250; %Where the edge detection start
    %C_Artefact = C3(:,3500:4800);
    [m,n] = size(C_Artefact);
    for x = 1:n %make everthing behind the pipe black & until this line the edge will be detected
        C_Artefact(lbound:m,x) = 0;
    end
    % figure;
    colormap gray;
    imagesc(C_Artefact);
    MaskC_Artefact = zeros(m,n);

    for x = 1:n %fill the holes behind the pipe edge  
        for y = ubound : lbound
            if (y+100) > m
                disp('matrix limitations exceeding2') % why does this happen, todo
            end
            if(C_Artefact(y,x) == 1 && C_Artefact(y-1,x) == 0 && C_Artefact(y+100,x)== 0)
                C_Artefact(y,x) = 0;
                MaskC_Artefact(y,x) = 1;
            end
        end
    end
    
    % figure;
    colormap gray;
    imagesc(C_Artefact);
    LineEdge = zeros(n,1);
    Diameter = zeros(round(n/2),1);

    for x = 1:n %Detect the edge of the pipe
        for y = 150:320
            if(C_Artefact(y,x) == 0 && C_Artefact(y-1,x) == 1) 
                LineEdge(x) = y;
            end
        end
    end
    %%
    %Sometimes the pipe is not detected, use the value from above 
    if(LineEdge(1) == 0)
        LineEdge(1) = LineEdge(2);
    end
    for i1 = 2:n
        if(LineEdge(i1) == 0)
            LineEdge(i1) = LineEdge(i1-1);
        end
    end

    %Filtering the detected Line, if the value jumps more  than 3 pixels from
    %column to another, then jump only one pixel (is probably a disturbance)
    for x = 2:n
        if(LineEdge(x-1) > LineEdge(x) + 3)
            LineEdge(x) = LineEdge(x-1) - 1;
        end
        if(LineEdge(x-1) < LineEdge(x) - 3)
            LineEdge(x) = LineEdge(x-1) + 1;
        end
    end
    % figure
    title('Detected Line unfiltered');
    plot(1:n,LineEdge);

    %Median Filter
     ylim([0,500]);
     LineEdgeMedian = medfilt1(LineEdge,20);
     for x = 1 : 2
         LineEdgeMedian = medfilt1(LineEdgeMedian,20);
     end
     % figure;
     title('Median Filter');
     plot(n,LineEdgeMedian);
     ylim([0,500]);

     %Mittelwert Filter
    windowSize = 30; 
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    for x = 1:2
        LineEdgeMedian = filter(b,a,LineEdgeMedian);
    end
    % figure
    title('Mittelwert');
     plot(1:n,LineEdge);
     ylim([0,500]);

    %Don´t use the first k filtered elements for the line
    k = 100; %Maybe k is constant
    LineEdge(k:n) = LineEdgeMedian(k:n);
    % figure
    title('filtered Line');
    plot(1:n,LineEdge);
    ylim([0,500]);

    %Make a Matrix to convert to cartesian
    Edge = zeros(512,n);
    EdgeEdge = zeros(512,n);
    LineEdge = (round(LineEdge));
    for x = 1:n
        for i = 1:LineEdge(x)
                Edge(i,x) = 1;
        end
        EdgeEdge(LineEdge(x),x) = 1;
    end
    
    
    %%
    %Move the Picture to get real calculations
    % figure;
    imagesc(Edge);
    N = 512*2;
    M = N;
    fprintf("Computing PolarToIm for EdgeimR\n");
    EdgeEdgeimR = PolarToIm(EdgeEdge, 0, 1, M, N);
    EdgeimR = PolarToIm(Edge, 0, 1, M, N);
    % figure;
    colormap gray;
    EdgeimR = im2bw(EdgeimR, 0.4);
    EdgeEdgeimR = im2bw(EdgeEdgeimR, 0.4);
    imagesc(EdgeimR);
    hold on;
    
    % Mittelpunkt des Kreises bestimmen    
    xi = 0;
    yi = 0;
    Ai = 0;
    sumup = 0;
    sumden = 0;

    for k = 1:1024
        Ai = 0;
        for l = 1:1024
            if EdgeimR(l,k) == 1
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
            if EdgeimR(k,l) == 1
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
    plot(512,512,'g*');
    %Shiften
    drx = (-1) * (xs - N/2);
    dry = (-1) * (ys - N/2);
    EdgeimRShift = circshift(EdgeimR,drx,1);
    EdgeimRShift = circshift(EdgeimRShift,dry,2);
    hold off
    % figure;
    colormap gray
    imagesc(EdgeimRShift);
    hold on;
    plot(512 + dry, 512 + drx,'*');
    plot(512,512,'g*')
    fprintf("Computing ImToPolar\n");
    EdgeimP = ImToPolar (EdgeimRShift, 0, 1, M/2, n);
    hold off
    % figure;
    colormap gray
    imagesc(EdgeimP)
    for i = 1:n
        for j =100:m-100
            if(EdgeimP(j,i) < 1 && EdgeimP(j-1,i) == 1)
                EdgeShift(i) = j-1; 
            end
        end
    end
    % Detect the Diameter
    % the row in which the pipe was detected in one B-Scan + row of the edge of a B-Scan after half a rotation
    % asuming that the rotation was constant during one B-Scan
    ne = size(EdgeShift,2)/2;
    for i = 1:round(ne)
         if ((i+(round(ne)) > round(2*ne)) && i > 1)
%                  disp('exceeding matrix limitations3')
                 Diameter(i) = Diameter(i-1);
         else
                 Diameter(i) = EdgeShift(i) + EdgeShift(i+(round(ne)));
         end
     end
     m = 1;
     %LineKartesian = zeros(N,N); %fbr
     for i = 1:N
         for j = 1:N
             if (EdgeEdgeimR(i,j) > 0.5)
                 LineKartesian(1,m) = i;
                 LineKartesian(2,m) = j;
                 m = m + 1;
             end
         end
     end
     %figure;
     hold off
     colormap gray
     fprintf("Computing PolarToIm\n");
     CKartesian = PolarToIm (C, 0, 1, M, N);
     imagesc(CKartesian)
     hold on
     [mL,nL] = size(LineKartesian);
     for i = 1:nL
         plot(LineKartesian(2,i),LineKartesian(1,i),'.r');
     end
     hold off
    %%
    %RadialMin           = min(LineEdge);% to see if there is a ZERO 
    %RadialMax           = max(LineEdge);
    DiameterMin         = min(Diameter)*0.0045/1.33;
    DiameterMax         = max(Diameter)*0.0045/1.33;
    DiameterEverage     = mean(Diameter)*0.0045/1.33;
    % DiameterIntervall   = DiameterMax - DiameterMin;
    % DiameterDelta = 0;
%     for i = 1 : round(ne/2)
%         DiameterDelta = DiameterDelta + (DiameterEverage - Diameter(i))^2;
%     end
    % DiameterError = sqrt(DiameterDelta/round(ne/2));
end