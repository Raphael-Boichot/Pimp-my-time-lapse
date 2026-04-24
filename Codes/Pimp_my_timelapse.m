clc;
clear;
close all;

% --- 1. List all MP4 files in the directory ---
listeVideos = dir('*.mp4');
% pick a frame every n (and drop the others)
downsampling = 10;

numVideos = length(listeVideos);
fprintf('Total number of videos to process: %d\n', numVideos);
fprintf('-------------------------------------------\n');

% --- 2. Global processing loop ---
for i = 1:numVideos
    % Close previous figures to manage memory
    close all;

    videoName = listeVideos(i).name;
    fprintf('[%d/%d] Currently processing: %s\n', i, numVideos, videoName);

    % Step A: Extract frames from video
    Image_extraction(videoName,downsampling); %Extract individual frames, droping some
    Image_fusion(videoName(5:18)); %Extract maximum, minimum and averga of all frames
    Image_time_slicer(videoName(5:18)); %Create time-slice visualization
    Image_time_slicer_diag(videoName(5:18)); %Create time-slit visualization in diagonal
    Image_time_slicer_circle(videoName(5:18)); %Create time-slit visualization in circle
    Image_time_slicer_block(videoName(5:18)); %Create time-slit visualization in squares
    Image_time_slicer_pie(videoName(5:18)); %Create time-slit visualization in pie chart
    Image_time_slit(videoName(5:18)); %Create time-slit visualization
end

fprintf('-------------------------------------------\n');
fprintf('Processing complete!\n');
close all;