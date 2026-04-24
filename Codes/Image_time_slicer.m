function []=Image_time_slicer(prefix)
close all;
inputFolder = 'Individual_frames';
outputFolder = 'Fusion_of_frames';
A = dir(fullfile(inputFolder, '*.png'));
img1 = imread(fullfile(inputFolder, A(1).name));
[h, w, c] = size(img1);
num_files = length(A);
fwd_scan = zeros(h, w, c, 'uint8'); % Left -> Right
bwd_scan = zeros(h, w, c, 'uint8'); % Right -> Left
up_down_scan = zeros(h, w, c, 'uint8'); % Top -> Bottom
down_up_scan = zeros(h, w, c, 'uint8'); % Bottom -> Top
slice_w = w / num_files;
slice_h = h / num_files;

fprintf('Generating 4-way Spatial Scans from %d images...\n', num_files);

% --- Processing Loop ---
for k = 1:num_files
    img = imread(fullfile(inputFolder, A(k).name));

    % 1. HORIZONTAL LOGIC (Columns)
    % Forward (Left to Right)
    l_fwd = round((k-1) * slice_w) + 1;
    r_fwd = round(k * slice_w);
    if r_fwd > w, r_fwd = w; end
    fwd_scan(:, l_fwd:r_fwd, :) = img(:, l_fwd:r_fwd, :);

    % Backward (Right to Left)
    k_rev_h = num_files - k + 1;
    l_bwd = round((k_rev_h-1) * slice_w) + 1;
    r_bwd = round(k_rev_h * slice_w);
    if r_bwd > w, r_bwd = w; end
    bwd_scan(:, l_bwd:r_bwd, :) = img(:, l_bwd:r_bwd, :);

    % 2. VERTICAL LOGIC (Rows)
    % Up-Down (Top to Bottom)
    t_ud = round((k-1) * slice_h) + 1;
    b_ud = round(k * slice_h);
    if b_ud > h, b_ud = h; end
    up_down_scan(t_ud:b_ud, :, :) = img(t_ud:b_ud, :, :);

    % Down-Up (Bottom to Top)
    k_rev_v = num_files - k + 1;
    t_du = round((k_rev_v-1) * slice_h) + 1;
    b_du = round(k_rev_v * slice_h);
    if b_du > h, b_du = h; end
    down_up_scan(t_du:b_du, :, :) = img(t_du:b_du, :, :);

    % Visual Feedback (showing 4-quadrant progress)
    if mod(k, 25) == 0 || k == num_files
        subplot(2,2,1); imshow(fwd_scan); title('Left -> Right');
        subplot(2,2,2); imshow(bwd_scan); title('Right -> Left');
        subplot(2,2,3); imshow(up_down_scan); title('Top -> Bottom');
        subplot(2,2,4); imshow(down_up_scan); title('Bottom -> Top');
        sgtitle(sprintf('Overall Progress: %d%%', round(k/num_files*100)));
        drawnow;
    end
end

% --- Save Results ---
save_list = {
    fwd_scan, 'FORWARD_LR';
    bwd_scan, 'BACKWARD_RL';
    up_down_scan, 'UP_DOWN';
    down_up_scan, 'DOWN_UP'
    };

for i = 1:size(save_list, 1)
    outName = fullfile(outputFolder, sprintf('%s_SlitScan_%s.png',prefix, save_list{i,2}));
    imwrite(save_list{i,1}, outName);
    fprintf('Saved: %s\n', outName);
end

fprintf('\nAll 4 spatial scans completed successfully!\n');