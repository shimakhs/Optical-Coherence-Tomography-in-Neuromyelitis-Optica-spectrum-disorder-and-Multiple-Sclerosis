% -*- MATLAB -*-
% Description:
% This script processes OCT .vol files to compute the thickness of retinal layers.
% It uses boundary data from the BScanHeader to calculate and export the thickness 
% of multiple retinal layers for each .vol file in the current directory.

% Inputs:
% - .vol files located in the current working directory.
%
% Outputs:
% - `test.xls`: An Excel file containing the thickness measurements of retinal layers
%   for each .vol file.

% ------------------ Initialize Workspace ------------------
close all; 
clear all;

% ------------------ Get List of .vol Files ------------------
dirData = dir('*.vol'); % List of all .vol files in the directory
numFiles = size(dirData, 1); % Count of .vol files
C = cell(numFiles, 11); % Preallocate cell array for results

% ------------------ Create Circular Mask ------------------
% Generate a 512x512 binary mask with a circular region
mask = ones(512, 512);
for i = 1:512
    for j = 1:512
        if (i - 256)^2 + (j - 256)^2 > 256^2
            mask(i, j) = 0;
        end
    end
end

% ------------------ Process Each .vol File ------------------
for count = 1:numFiles
    % Store the file name
    C{count, 1} = dirData(count).name;

    % Open the .vol file and extract necessary data
    [header, BScanHeader, slo, BScans, ThicknessGrid] = open_vol(dirData(count).name);

    % Replace invalid BScan values with zero
    BScans(BScans > 1e+38) = 0;

    % Check the number of segmentation boundaries
    if BScanHeader.NumSeg ~= 3  
        % Initialize array to store thickness maps for 11 layers
        thick_allLayers = zeros(512, 512, 11);

        % Compute thickness for each retinal layer
        thick_allLayers(:, :, 1) = imresize(BScanHeader.Boundary_2 - BScanHeader.Boundary_1, [512, 512]);
        thick_allLayers(:, :, 2) = imresize(BScanHeader.Boundary_3 - BScanHeader.Boundary_1, [512, 512]);
        thick_allLayers(:, :, 3) = imresize(BScanHeader.Boundary_4 - BScanHeader.Boundary_3, [512, 512]);
        thick_allLayers(:, :, 4) = imresize(BScanHeader.Boundary_5 - BScanHeader.Boundary_4, [512, 512]);
        thick_allLayers(:, :, 5) = imresize(BScanHeader.Boundary_6 - BScanHeader.Boundary_5, [512, 512]);
        thick_allLayers(:, :, 6) = imresize(BScanHeader.Boundary_7 - BScanHeader.Boundary_6, [512, 512]);
        thick_allLayers(:, :, 7) = imresize(BScanHeader.Boundary_9 - BScanHeader.Boundary_7, [512, 512]);
        thick_allLayers(:, :, 8) = imresize(BScanHeader.Boundary_15 - BScanHeader.Boundary_9, [512, 512]);
        thick_allLayers(:, :, 9) = imresize(BScanHeader.Boundary_16 - BScanHeader.Boundary_15, [512, 512]);
        thick_allLayers(:, :, 10) = imresize(BScanHeader.Boundary_17 - BScanHeader.Boundary_16, [512, 512]);
        thick_allLayers(:, :, 11) = imresize(BScanHeader.Boundary_2 - BScanHeader.Boundary_17, [512, 512]);

        % Apply mask and compute mean thickness for valid regions
        for layer = 1:11
            thickTemp = thick_allLayers(:, :, layer);
            mask2 = ones(512, 512);
            mask2((thickTemp * header.ScaleZ > 1)) = 0; % Filter incorrect large values
            mask2((thickTemp * header.ScaleZ < 0)) = 0; % Filter negative values
            validRegion = (mask == 1) & (mask2 == 1);
            C{count, layer + 1} = mean(thickTemp(validRegion)) * header.ScaleZ;
        end
    else
        % Process cases with fewer segmentation boundaries
        pRNFL = BScanHeader.Boundary_3 - BScanHeader.Boundary_1;

        % Compute mean thickness for specific regions
        C{count, 2} = mean([pRNFL(1:96), pRNFL(768 - 96 + 1:768)]) * header.ScaleZ;
        C{count, 3} = mean(pRNFL(97:96 + 192)) * header.ScaleZ;
        C{count, 4} = mean(pRNFL(97 + 192:96 + 192 + 192)) * header.ScaleZ;
        C{count, 5} = mean(pRNFL(97 + 192 + 192:768 - 96)) * header.ScaleZ;

        % Compute mean thickness for quadrants
        C{count, 6} = mean(pRNFL(97:96 + 96)) * header.ScaleZ;
        C{count, 7} = mean(pRNFL(96 + 97:96 + 192)) * header.ScaleZ;
        C{count, 8} = mean(pRNFL(97 + 192 + 192:96 + 192 + 192 + 96)) * header.ScaleZ;
        C{count, 9} = mean(pRNFL(97 + 192 + 192 + 96:96 + 192 + 192 + 192)) * header.ScaleZ;

        % Compute average thickness across regions
        C{count, 10} = mean([C{count, 2}, C{count, 3}, C{count, 4}, C{count, 5}]);
    end
end

% ------------------ Export Results to Excel ------------------
xlswrite('test.xls', C);
