function [] = Image_extraction(videoFileName, n)
% n: the interval (e.g., n=5 saves every 5th frame)

outputFolder1 = 'Individual_frames';

% --- FOLDER CLEANOUT ---
if exist(outputFolder1, 'dir')
    fprintf('Cleaning up old frames in: %s...\n', outputFolder1);
    rmdir(outputFolder1, 's'); 
end
mkdir(outputFolder1);

% --- EXTRACTION ---
v1 = VideoReader(videoFileName);
numFrames = floor(v1.Duration * v1.FrameRate);
fprintf('Reading %s. Extracting every %d frames...\n', videoFileName, n);

k = 1;      % Global frame counter
savedCount = 1; % Filename counter

while hasFrame(v1)
    % Read the frame (this advances the VideoReader pointer)
    img = readFrame(v1);
    
    % Only save if the current frame index is a multiple of n
    if mod(k, n) == 0
        outputBaseFileName = sprintf('%04d.png', savedCount);
        outputFullFileName = fullfile(outputFolder1, outputBaseFileName);
        imwrite(img, outputFullFileName);
        
        fprintf('Saved frame %d (Video Frame Index: %d / %d)\n', savedCount, k, numFrames);
        savedCount = savedCount + 1;
    end
    
    k = k + 1;
end

disp('Extraction complete!')
end