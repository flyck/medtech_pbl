%% Gruppe1 PBL - Main

% to call functions within this matlab file from outside (the gui) we need
% this form of a main function, due to hints in this link:
% https://de.mathworks.com/matlabcentral/newsreader/view_thread/282878
function C = PBL_Main(sequence, argument)
    switch sequence
        case "init"
            C = init(argument);
        case "main"
            C = main();
    end
end

function C = main
    C = init();

    % Convert the MScan into BScans using one of our methods: 
    % Felix's method
    %PBL_MScan2Bscan_Gapfinder();
    % Alexandra's method
    MtoBscan(C);
    
    % Filter artefacts
    PBL_Filter_Artefacts();

    % Determine Diameter
    % C shouldnt have artifacts at this point! Otherwise the diameter cant be
    % computed correctly.
    PBL_Determine_Diameter();
end

% Load the measured data into the workspace.
function C = init(filename)
    clearvars -except Offset Chirp filename
    % close all % commented since this closes the gui!

    %Rohdatenverarbeitung();
    % Doesnt need to be called from main? Interrupts testing of everything else

    %filename = '09052017034909__ascan_3.bin';
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
end

function extra
%%
% remove Artefacts
% looks weird ´, there´s a black patch in the middle 
% 
% J = imtranslate(C,[0, -175]);
% figure ('name','shifted image')
% imagesc(J)
% J = imtranslate(J,[0, 175]);
% figure ('name','remove Artefacts')
% imagesc(J)
%%
% Compute and display the scans in cartesian coordinates
%InterpolationTransformation();

%% 
% Sample Interpolation and coordinate transformation
% 
% FinishedBScan = C(:,3500:4900); %todo, artefact 2 algo left out here
% FinishedBScan(1:150,:) = 1;
% figure; %attempt to correct the image display
% imagesc(FinishedBScan);
% figure;
% N = 512*2;
% M = N;
% imR = PolarToIm (FinishedBScan, 0, 1, M, N);
% imagesc(imR);
end