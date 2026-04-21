function []=Image_extraction(videoFileName)
outputFolder1 = 'Individual_frames';

% --- FOLDER CLEANOUT ---
% Deletes the folder and all its contents, then recreates it empty
if exist(outputFolder1, 'dir')
    fprintf('Cleaning up old frames in: %s...\n', outputFolder1);
    rmdir(outputFolder1, 's'); 
end
mkdir(outputFolder1);

% --- EXTRACTION ---
v1 = VideoReader(videoFileName);
numFrames = floor(v1.Duration * v1.FrameRate);

disp('Reading MP4 file and decomposing into frames...')

k = 1;
% Using a while loop with readFrame is more memory-efficient than read(v1)
while hasFrame(v1)
    % Read a single frame
    img = readFrame(v1);
    outputBaseFileName = sprintf('%4.4d.png', k);
    outputFullFileName = fullfile(outputFolder1, outputBaseFileName);
    imwrite(img, outputFullFileName);
    disp(['Extracting frame ', outputFullFileName, ' / ', num2str(numFrames)]);
    k = k + 1;
end

disp('Extraction complete !')
