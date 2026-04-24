function []=Image_fusion(prefix)
close all;
inputFolder = 'Individual_frames';
outputFolder = 'Fusion_of_frames';
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end
A = dir(fullfile(inputFolder, '*.png'));
if isempty(A)
    error('No images found.');
end

image_path = fullfile(inputFolder, A(1,1).name);
image_first = imread(image_path);
[height, width, channels] = size(image_first);
averageImg = zeros(height, width, channels);
maximumImg = zeros(height, width, channels);
minimumImg = 255 .* ones(height, width, channels);

% --- Processing Loop ---
N = length(A);
for k = 1:N
    currentImg = double(imread(fullfile(inputFolder, A(k,1).name)));
    averageImg = averageImg + (currentImg ./ N);
    maximumImg = max(maximumImg, currentImg);
    minimumImg = min(minimumImg, currentImg);
    if mod(k, 10) == 0 || k == N
        fprintf('Processing: %d/%d\n', k, N);
    end
end

% --- Save Results (Timestamp at the start of filenames) ---
imwrite(uint8(averageImg), fullfile(outputFolder, [prefix, '_Average_Image.png']));
imwrite(uint8(maximumImg), fullfile(outputFolder, [prefix, '_Maximum_Image.png']));
imwrite(uint8(minimumImg), fullfile(outputFolder, [prefix, '_Minimum_Image.png']));