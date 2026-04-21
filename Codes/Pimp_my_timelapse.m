clc;
clear;
close all;

% --- 1. List all MP4 files in the directory ---
listeVideos = dir('*.mp4');
% pick a frame every n (and drop the others)
downsampling = 20;

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
    run('Image_fusion.m'); %Extract maximum, minimum and averga of all frames
    run('Image_time_slicer.m'); %Create time-slice visualization
    run('Image_time_slicer_diag.m'); %Create time-slit visualization in diagonal
    run('Image_time_slicer_circle.m'); %Create time-slit visualization in circle
    run('Image_time_slicer_block.m'); %Create time-slit visualization in squares
    run('Image_time_slicer_pie.m'); %Create time-slit visualization in pie chart
    run('Image_time_slit.m'); %Create time-slit visualization
    pause(2); % Buffer for figure rendering
end

fprintf('-------------------------------------------\n');
fprintf('Processing complete!\n');
close all;