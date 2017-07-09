close all; 
%% Filters artefacts
    % Parameters:
    medfilt2_iteration_Th = 4; % amount of times medfilt2 should be executed
    im2bw_Th_1 = 0.35; % threshhold for first im2bw
    gaussfilt_Th = 5; % amount of times to execute gaussian filter
    im2bw_Th_2 = 0.6; % threshhold for second im2bw
    CatheterArtefactLower = 160;
    original(:,:) = C; % used for backup later
    %% 
    figure;
    imagesc(C);
    % Increase contrast
    figure;
    C = histeq(C); %possible alternative: imadjust(), gives worse results though
    colormap gray;
    imagesc(C);
    figure;
    colormap gray;
    C(1:CatheterArtefactLower,:) = 0;
     %% 
%     % Smooth it out and binarize it
% 
     for i = 1:medfilt2_iteration_Th
         C = medfilt2(C,[3,3]);
     end
%         colormap gray;
%     imagesc(C);
%     figure;
    C = im2bw(C, im2bw_Th_1);
    %% 
    % Try different filters for getting rid of noise and binarize it again

    C = im2double(C);
    C = imgaussfilt(C, 6);
    C = im2bw(C, im2bw_Th_2); % the higher the value the blacker the picture
    imagesc(C);
    %%  
    % Filtering the Artefact Line between Row 250 and 190

    C = imcomplement(C);
    C = im2double(C);
    Artefact_mask = zeros(size(C));
    [m,n] = size(C);
    for i = n-10 : -1 : 1 
        for j =  250 :-1: 190
            % überprüfe die beiden Punkte darunter auf weiß und einen Punkt 10 weiter rechts von dem schwarzen Punkt ausgehend
            if((C(j,i)==0) && (C(j + 1,i) == 1) && (C(j + 2,i) == 1) && (C(j+2,i+10) == 1)) 
                C(j,i) = 1;
                Artefact_mask(j,i) = 1;
            end
        end
        if (round(3*n/4) == i) 
            disp('25% der Artefakte gefiltert') 
        end
        if (round(n/2) == i) 
            disp('50% der Artefakte gefiltert') 
        end
        if (round(n/4) == i) 
            disp('75% der Artefakte gefiltert') 
        end
        if (2 == i) 
            disp('100% der Artefakte gefiltert') 
        end
    end
     colormap gray;
    imagesc(Artefact_mask);
    figure;
    %% 
    % Filtering Peaks and Lows (doesnt work well yet)
    % Artefact2_finish = finish-10; %um den ganzen Bereich zu scannen
    % for i = 11 : Artefact2_finish
    %     for j =  170:300
    %         if((Artefact_mask(j,i)==0) && ((Artefact1(j,i+10) == 1) && Artefact1(j,i-10) == 1)) 
    %             Artefact_mask(j,i) = 1;
    %         end
    %     end
    %     if (round(Artefact2_finish/4) == i) 
    %         disp("25% erreicht") 
    %     end
    %     if (round(Artefact2_finish/2) == i) 
    %         disp("50% erreicht") 
    %     end
    %     if (round(3*Artefact2_finish/4) == i) 
    %         disp("75% erreicht") 
    %     end
    % end
    % disp("100% erreicht")
    %% 
    % Apply and show the previously computed mask
    C_Artefact = C;
    colormap gray;
    imagesc(C_Artefact);
    figure;
    colormap gray;
    C = original;
    grey_val = 0.4; % todo manueller wert
    for j = 250 : -1 : 190
        for i = 1 : 1 : n
            if (Artefact_mask(j,i) == 1)
                C(j,i) = grey_val;
            end
        end
    end
    colormap gray;
    imagesc(C_Artefact)