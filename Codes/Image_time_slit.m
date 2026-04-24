function []=Image_time_slit(prefix)

close all;
inputFolder = 'Individual_frames';
outputFolder = 'Fusion_of_frames';
A = dir(fullfile(inputFolder, '*.png'));
num_files = length(A);
img1 = imread(fullfile(inputFolder, A(1).name));
[h, w, c] = size(img1);

% --- Pre-allocation ---
% Vertical Slit (Center Column)
v_stack_fwd = zeros(h, num_files, c, 'uint8'); % Time: Left -> Right
v_stack_bwd = zeros(h, num_files, c, 'uint8'); % Time: Right -> Left
% Horizontal Slit (Center Row)
h_stack_fwd = zeros(num_files, w, c, 'uint8'); % Time: Top -> Bottom
h_stack_bwd = zeros(num_files, w, c, 'uint8'); % Time: Bottom -> Top

% Calculate center indices
mid_w = round(w / 2);
mid_h = round(h / 2);
fprintf('Processing %d images for 4-way Slit-Scan extraction...\n', num_files);

% --- Processing Loop ---
for k = 1:num_files
    % Load image once per iteration
    img = imread(fullfile(inputFolder, A(k).name));
    % Temporal indices
    idx_fwd = k;
    idx_bwd = num_files - k + 1;
    % 1. Vertical Slit Logic (Center Column)
    v_line = img(:, mid_w, :);
    v_stack_fwd(:, idx_fwd, :) = v_line;
    v_stack_bwd(:, idx_bwd, :) = v_line;
    % 2. Horizontal Slit Logic (Center Row)
    h_line = img(mid_h, :, :);
    h_stack_fwd(idx_fwd, :, :) = h_line;
    h_stack_bwd(idx_bwd, :, :) = h_line;
    % Visual Feedback every 25 frames
    if mod(k, 25) == 0 || k == num_files
        subplot(2,2,1); imshow(v_stack_fwd); title('Vert. Slit (L \rightarrow R)');
        subplot(2,2,2); imshow(v_stack_bwd); title('Vert. Slit (R \rightarrow L)');
        subplot(2,2,3); imshow(h_stack_fwd); title('Horiz. Slit (T \rightarrow B)');
        subplot(2,2,4); imshow(h_stack_bwd); title('Horiz. Slit (B \rightarrow T)');
        % Progression in Super Title
        prog = round((k/num_files)*100);
        sgtitle(sprintf('Slit-Scan Progression: %d/%d (%d%%)', k, num_files, prog));
        drawnow;
    end
end

% --- Save Results ---
out_data = {
    v_stack_fwd, 'Vert_LR';
    v_stack_bwd, 'Vert_RL';
    h_stack_fwd, 'Horiz_TB';
    h_stack_bwd, 'Horiz_BT'
    };

for i = 1:size(out_data, 1)
    fileName = fullfile(outputFolder, sprintf('%s_SlitStack_%s.png', prefix, out_data{i,2}));
    imwrite(out_data{i,1}, fileName);
end

fprintf('\nSuccess! 4 directions saved with timestamp: %s\n', prefix);