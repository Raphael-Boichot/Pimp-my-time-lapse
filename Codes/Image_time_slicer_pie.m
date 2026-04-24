function []=Image_time_slicer_pie(prefix)
close all;
inputFolder = 'Individual_frames';
outputFolder = 'Fusion_of_frames';
A = dir(fullfile(inputFolder, '*.png'));
img1 = imread(fullfile(inputFolder, A(1).name));
[h, w, c] = size(img1);
num_files = length(A);

% --- Pre-allocation ---
pieTL = zeros(h, w, c, 'uint8');
pieTR = zeros(h, w, c, 'uint8');
pieBL = zeros(h, w, c, 'uint8');
pieBR = zeros(h, w, c, 'uint8');

% Create coordinate grids
[X, Y] = meshgrid(1:w, 1:h);

% --- Corrected Angular Normalization ---
% We use atan2 and then normalize the 90-degree span to [0, 1]
% Top-Left (Origin 1,1): Angle is 0 to pi/2
angleTL = atan2(Y-1, X-1) / (pi/2);
% Top-Right (Origin w,1): Angle is pi/2 to pi
angleTR = (atan2(Y-1, X-w) - pi) / (-pi/2);
% Bottom-Left (Origin 1,h): Angle is -pi/2 to 0
angleBL = atan2(Y-h, X-1) / (-pi/2);
% Bottom-Right (Origin w,h): Angle is -pi to -pi/2
angleBR = (atan2(Y-h, X-w) + pi) / (pi/2);
% Ensure all are clamped/cleaned to 0-1 range to prevent precision leakage
angleTL = max(0, min(1, angleTL));
angleTR = max(0, min(1, angleTR));
angleBL = max(0, min(1, angleBL));
angleBR = max(0, min(1, angleBR));
step = 1 / num_files;
fprintf('Processing %d images with fixed radial logic...\n', num_files);

for k = 1:num_files
    img = imread(fullfile(inputFolder, A(k).name));
    low = (k-1) * step;
    high = k * step;
    % Masks
    mTL = (angleTL >= low) & (angleTL < high);
    mTR = (angleTR >= low) & (angleTR < high);
    mBL = (angleBL >= low) & (angleBL < high);
    mBR = (angleBR >= low) & (angleBR < high);
    for chan = 1:c
        curr = img(:,:,chan);
        t = pieTL(:,:,chan); t(mTL) = curr(mTL); pieTL(:,:,chan) = t;
        t = pieTR(:,:,chan); t(mTR) = curr(mTR); pieTR(:,:,chan) = t;
        t = pieBL(:,:,chan); t(mBL) = curr(mBL); pieBL(:,:,chan) = t;
        t = pieBR(:,:,chan); t(mBR) = curr(mBR); pieBR(:,:,chan) = t;
    end
    if mod(k, 25) == 0 || k == num_files
        subplot(2,2,1); imshow(pieTL); title('Top-Left');
        subplot(2,2,2); imshow(pieTR); title('Top-Right');
        subplot(2,2,3); imshow(pieBL); title('Bottom-Left');
        subplot(2,2,4); imshow(pieBR); title('Bottom-Right');
        sgtitle(sprintf('Progress: %d%%', round((k/num_files)*100)));
        drawnow;
    end
end

% --- Save Results ---
res = {pieTL,'TL'; pieTR,'TR'; pieBL,'BL'; pieBR,'BR'};
for i = 1:4
    fn = fullfile(outputFolder, sprintf('%s_Pie_%s.png', prefix, res{i,2}));
    imwrite(res{i,1}, fn);
    fprintf('Saved: %s\n', fn);
end