function []=Image_time_slicer_circle(prefix)
close all;
inputFolder = 'Individual_frames';
outputFolder = 'Fusion_of_frames';
A = dir(fullfile(inputFolder, '*.png'));
num_files = length(A);
img1 = imread(fullfile(inputFolder, A(1).name));
[h, w, c] = size(img1);

% --- Pre-allocation ---
circ_out_fwd = zeros(h, w, c, 'uint8');
circ_out_bwd = zeros(h, w, c, 'uint8');

% --- Coordinate Math (Circular) ---
% Find the center of the image
center_x = w / 2;
center_y = h / 2;
[X, Y] = meshgrid(1:w, 1:h);

% Calculate the distance of each pixel from the center (Euclidean distance)
% Distance = sqrt((x-cx)^2 + (y-cy)^2)
dist_from_center = sqrt((X - center_x).^2 + (Y - center_y).^2);

% Maximum possible distance (corner of the image)
max_dist = max(dist_from_center(:));
step = max_dist / num_files;

fprintf('Generating Circular Slit-Scans from %d images...\n', num_files);
figure('Name', 'Circular Slit-Scan Progress', 'NumberTitle', 'off');

% --- Processing Loop ---
for k = 1:num_files
    img = imread(fullfile(inputFolder, A(k).name));
    % Temporal indices
    k_fwd = k;
    k_bwd = num_files - k + 1;
    % 1. Center to Edges Mask (Forward)
    % The "ring" starts at the center and grows outwards
    d_start_f = (k_fwd-1) * step;
    d_end_f   = k_fwd * step;
    mask_fwd = (dist_from_center >= d_start_f) & (dist_from_center < d_end_f);
    % 2. Edges to Center Mask (Backward/Reverse)
    % The "ring" starts at the corners and shrinks to the center
    d_start_b = (k_bwd-1) * step;
    d_end_b   = k_bwd * step;
    mask_bwd = (dist_from_center >= d_start_b) & (dist_from_center < d_end_b);
    % Apply masks to RGB channels
    for chan = 1:c
        img_c = img(:,:,chan);
        % Update Forward Scan
        tmp_f = circ_out_fwd(:,:,chan);
        tmp_f(mask_fwd) = img_c(mask_fwd);
        circ_out_fwd(:,:,chan) = tmp_f;
        % Update Backward Scan
        tmp_b = circ_out_bwd(:,:,chan);
        tmp_b(mask_bwd) = img_c(mask_bwd);
        circ_out_bwd(:,:,chan) = tmp_b;
    end

    % Visual Feedback
    if mod(k, 25) == 0 || k == num_files
        subplot(1,2,1); imshow(circ_out_fwd); title('Center \rightarrow Edges');
        subplot(1,2,2); imshow(circ_out_bwd); title('Edges \rightarrow Center');
        prog = round((k/num_files)*100);
        sgtitle(sprintf('Circular Progress: %d/%d (%d%%)', k, num_files, prog));
        drawnow;
    end
end

% --- Save Results ---
imwrite(circ_out_fwd, fullfile(outputFolder, [prefix, '_CircularScan_CenterOut.png']));
imwrite(circ_out_bwd, fullfile(outputFolder, [prefix, '_CircularScan_EdgesIn.png']));
fprintf('\nSuccess! Circular scans saved in: %s\n', outputFolder);