% This function returns the scanned image without the artefacts introduced
% by the measurement device.
function [C_Artefacts, C] = PBL_Filter_Artefacts(C)
    %% Filters artefacts
    % Parameters:
    medfilt2_iteration_Th = 4; % amount of times medfilt2 should be executed
    im2bw_Th_1 = 0.53; % threshhold for first im2bw
    gaussfilt_Th = 6; % amount of times to execute gaussian filter
    im2bw_Th_2 = 0.45; % threshhold for second im2bw
    CatheterArtefactLower = 160;
    
    %figure;
    colormap gray;
    imagesc(C);
    
    %% 
    % Cut off the catheter at the top by greying it out
    C(1:CatheterArtefactLower,:) = 0.44;
    %figure;
    colormap gray;
    imagesc(C);
    
    %%
    % Copy the picture, this is later used to substract the computed mask
    % from it and then return it as a result
    
    original = C; % used for backup later
    
    %% 
    % Increase contrast

    C = histeq(C); %possible alternative: imadjust(), gives worse results though
    colormap gray;
    imagesc(C);
    %% 
    % Smooth it out and binarize it

    for i = 1:medfilt2_iteration_Th
        C = medfilt2(C,[3,3]);
    end
    C = im2bw(C, im2bw_Th_1);
    colormap gray;
    imagesc(C);
    C_Malte = C;
    %% 
    % Try different filters for getting rid of noise and binarize it again

    % C = im2double(C);
    % C = imgaussfilt(C, gaussfilt_Th);
    % C = im2bw(C, im2bw_Th_2); % the higher the value the blacker the picture
    % colormap gray;
    % imagesc(C);
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
    end
    imagesc(Artefact_mask);

    %% 
    % Apply and show the previously computed mask
    C_Artefacts = C;
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
    imagesc(C);
    %%
    % now create the Artefacts Malte needs
    CN = C_Malte;
    CN = im2double(CN);
    CN = imgaussfilt(CN, gaussfilt_Th);
    CN = im2bw(CN, im2bw_Th_2); % the higher the value the blacker the picture
    CN = imcomplement(CN);
    CN = im2double(CN);
    [m,n] = size(CN);
    for i = n-10 : -1 : 1 
        for j =  250 :-1: 190
            % überprüfe die beiden Punkte darunter auf weiß und einen Punkt 10 weiter rechts von dem schwarzen Punkt ausgehend
            if((CN(j,i)==0) && (CN(j + 1,i) == 1) && (CN(j + 2,i) == 1) && (CN(j+2,i+10) == 1)) 
                CN(j,i) = 1;
            end
        end
    end
    C_Artefacts = CN;
end