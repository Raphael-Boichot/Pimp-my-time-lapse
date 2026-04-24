function []=Image_time_slicer_diag(prefix)
close all;
inputFolder = 'Individual_frames';
outputFolder = 'Fusion_of_frames';
A = dir(fullfile(inputFolder, '*.png'));
img1 = imread(fullfile(inputFolder, A(1).name));
[h, w, c] = size(img1);
num_files = length(A);

% --- Pre-allocation ---
% 45 Degree Slits (X + Y)
diag45_fwd = zeros(h, w, c, 'uint8');
diag45_bwd = zeros(h, w, c, 'uint8');
% -45 Degree Slits (X - Y)
diagNeg45_fwd = zeros(h, w, c, 'uint8');
diagNeg45_bwd = zeros(h, w, c, 'uint8');

% Create coordinate grids
[X, Y] = meshgrid(1:w, 1:h);
idx45 = X + Y;            % Range: 2 to (w+h)
idxNeg45 = X - Y + h;     % Range: 1 to (w+h)

max_val = w + h;
step = max_val / num_files;

fprintf('Generating 4 Diagonal Scans from %d images...\n', num_files);

% --- Processing Loop ---
for k = 1:num_files
    img = imread(fullfile(inputFolder, A(k).name));
    % Temporal indices for Forward and Backward sweeps
    k_fwd = k;
    k_bwd = num_files - k + 1;
    % 1. 45-Degree Masks (X + Y)
    mask45_fwd = (idx45 >= (k_fwd-1)*step) & (idx45 < k_fwd*step);
    mask45_bwd = (idx45 >= (k_bwd-1)*step) & (idx45 < k_bwd*step);
    % 2. -45-Degree Masks (X - Y + h)
    maskNeg45_fwd = (idxNeg45 >= (k_fwd-1)*step) & (idxNeg45 < k_fwd*step);
    maskNeg45_bwd = (idxNeg45 >= (k_bwd-1)*step) & (idxNeg45 < k_bwd*step);
    % Apply masks to color channels
    for chan = 1:c
        img_c = img(:,:,chan);
        % Process 45° Forward/Backward
        tmp45f = diag45_fwd(:,:,chan); tmp45f(mask45_fwd) = img_c(mask45_fwd);
        diag45_fwd(:,:,chan) = tmp45f;
        tmp45b = diag45_bwd(:,:,chan); tmp45b(mask45_bwd) = img_c(mask45_bwd);
        diag45_bwd(:,:,chan) = tmp45b;
        % Process -45° Forward/Backward
        tmpN45f = diagNeg45_fwd(:,:,chan); tmpN45f(maskNeg45_fwd) = img_c(maskNeg45_fwd);
        diagNeg45_fwd(:,:,chan) = tmpN45f;
        tmpN45b = diagNeg45_bwd(:,:,chan); tmpN45b(maskNeg45_bwd) = img_c(maskNeg45_bwd);
        diagNeg45_bwd(:,:,chan) = tmpN45b;
    end

    % Visual Feedback with Progression in the Title
    if mod(k, 25) == 0 || k == num_files
        subplot(2,2,1); imshow(diag45_fwd); title('45° Forward');
        subplot(2,2,2); imshow(diag45_bwd); title('45° Backward');
        subplot(2,2,3); imshow(diagNeg45_fwd); title('-45° Forward');
        subplot(2,2,4); imshow(diagNeg45_bwd); title('-45° Backward');
        % Main title showing [Current Frame / Total] and Percentage
        prog_percent = round((k/num_files) * 100);
        sgtitle(sprintf('Progression: %d/%d (%d%%)', k, num_files, prog_percent));
        drawnow;
    end
end

% --- Save Results ---
outputs = {
    diag45_fwd, '45_FWD';
    diag45_bwd, '45_BWD';
    diagNeg45_fwd, 'Neg45_FWD';
    diagNeg45_bwd, 'Neg45_BWD'
    };

fprintf('\nSaving diagonal scan results...\n');
for i = 1:size(outputs, 1)
    fileName = fullfile(outputFolder, sprintf('%s_SlitScan_Diag_%s.png', prefix, outputs{i,2}));
    imwrite(outputs{i,1}, fileName);
    fprintf('Successfully saved: %s\n', fileName);
end

fprintf('\nDone! All 4 diagonal directions generated.\n');