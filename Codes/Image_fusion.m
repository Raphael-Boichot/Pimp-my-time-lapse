close all;

% --- Configuration ---
inputFolder = 'Individual_frames'; 
outputFolder = 'Fusion_of_frames'; 

% Create output directory if it doesn't exist
if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end

% Generate timestamp FIRST (Format: 2026-04-21_14-30)
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM');

% --- File Listing ---
% List all PNG files in the input folder
A = dir(fullfile(inputFolder, '*.png'));
if isempty(A), error('No images found.'); end

% Get dimensions from the first image
image_path = fullfile(inputFolder, A(1,1).name);
image_first = imread(image_path);
[height, width, channels] = size(image_first);

% --- Video Writer (Timestamp at the start of the filename) ---
%videoName = sprintf('%s_Maximum_Evolution.mp4', timestamp);
%videoPath = fullfile(outputFolder, videoName);
%v = VideoWriter(videoPath, 'MPEG-4');
%v.FrameRate = 30; 
%open(v);

% --- Initialization ---
% Pre-allocate matrices as doubles for precision during calculation
averageImg = zeros(height, width, channels);
maximumImg = zeros(height, width, channels);
minimumImg = 255 .* ones(height, width, channels);

% --- Processing Loop ---
N = length(A);
for k = 1:N
    % Load image and convert to double for mathematical operations
    currentImg = double(imread(fullfile(inputFolder, A(k,1).name)));
    
    % Update statistics
    averageImg = averageImg + (currentImg ./ N);
    maximumImg = max(maximumImg, currentImg);
    minimumImg = min(minimumImg, currentImg);
    
    % Add the current 'Maximum' state as a frame to the video
    %writeVideo(v, uint8(maximumImg));
    
    % Display progress every 10 frames
    if mod(k, 10) == 0 || k == N
        fprintf('Processing: %d/%d\n', k, N);
    end
end

%close(v); 

% --- Save Results (Timestamp at the start of filenames) ---
imwrite(uint8(averageImg), fullfile(outputFolder, [timestamp, '_Average_Image.png']));
imwrite(uint8(maximumImg), fullfile(outputFolder, [timestamp, '_Maximum_Image.png']));
imwrite(uint8(minimumImg), fullfile(outputFolder, [timestamp, '_Minimum_Image.png']));

fprintf('\nSuccess! Files created with prefix: %s\n', timestamp);