close all;

% --- Configuration ---
inputFolder = 'Individual_frames'; 
outputFolder = 'Fusion_of_frames'; 
if ~exist(outputFolder, 'dir'), mkdir(outputFolder); end

% Timestamp: 2026-04-21_17-30
timestamp = datestr(now, 'yyyy-mm-dd_HH-MM');

% --- File Discovery ---
A = dir(fullfile(inputFolder, '*.png'));
if isempty(A), error('No images found.'); end

num_files = length(A);
img1 = imread(fullfile(inputFolder, A(1).name));
[h, w, c] = size(img1);

% --- Mosaic Settings ---
% Define the number of blocks (e.g., 10x10 grid)
grid_cols = 10; 
grid_rows = 10;
num_blocks = grid_cols * grid_rows;

% Calculate size of each block
block_w = floor(w / grid_cols);
block_h = floor(h / grid_rows);

% Assign frames to blocks
% We map the available frames across the total number of blocks
frame_indices = round(linspace(1, num_files, num_blocks));
% For the random version:
rand_indices = frame_indices(randperm(num_blocks));

% --- Pre-allocation ---
mosaic_std = zeros(h, w, c, 'uint8');
mosaic_rnd = zeros(h, w, c, 'uint8');

fprintf('Generating Temporal Mosaics (%dx%d grid)...\n', grid_rows, grid_cols);

% --- Processing Loop ---
% To optimize, we loop through the blocks instead of the frames
block_count = 1;
for r = 1:grid_rows
    for col = 1:grid_cols
        % Calculate block coordinates
        y_range = (r-1)*block_h + 1 : r*block_h;
        x_range = (col-1)*block_w + 1 : col*block_w;
        
        % 1. Standard Mosaic: Load frame assigned to this block position
        idx_std = frame_indices(block_count);
        img_std = imread(fullfile(inputFolder, A(idx_std).name));
        mosaic_std(y_range, x_range, :) = img_std(y_range, x_range, :);
        
        % 2. Random Mosaic: Load a random frame for this block position
        idx_rnd = rand_indices(block_count);
        img_rnd = imread(fullfile(inputFolder, A(idx_rnd).name));
        mosaic_rnd(y_range, x_range, :) = img_rnd(y_range, x_range, :);
        
        % Visual Feedback
        if mod(block_count, 5) == 0 || block_count == num_blocks
            subplot(1,2,1); imshow(mosaic_std); title('Sequential Grid');
            subplot(1,2,2); imshow(mosaic_rnd); title('Random Grid');
            sgtitle(sprintf('Building Mosaic: %d%%', round(block_count/num_blocks*100)));
            drawnow;
        end
        
        block_count = block_count + 1;
    end
end

% --- Save Results ---
imwrite(mosaic_std, fullfile(outputFolder, [timestamp, '_Mosaic_Sequential.png']));
imwrite(mosaic_rnd, fullfile(outputFolder, [timestamp, '_Mosaic_Random.png']));

fprintf('\nMosaic generation complete!\n');