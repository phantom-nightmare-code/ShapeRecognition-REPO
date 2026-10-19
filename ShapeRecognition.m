function ShapeRecognition
% Launch the shape-recognition GUI.

fig = figure( ...
    'Name', 'Shape Recognition', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'Color', [0.94 0.95 0.97], ...
    'Position', [100 100 1100 650], ...
    'Resize', 'on');

axOriginal = axes('Parent', fig, 'Units', 'normalized', ...
    'Position', [0.34 0.18 0.29 0.70]);
title(axOriginal, 'Original Image');
axis(axOriginal, 'off');

axMask = axes('Parent', fig, 'Units', 'normalized', ...
    'Position', [0.66 0.18 0.29 0.70]);
title(axMask, 'Processed Binary Mask');
axis(axMask, 'off');

uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.03 0.89 0.26 0.06], ...
    'String', 'Shape Recognition', ...
    'FontSize', 16, 'FontWeight', 'bold', ...
    'BackgroundColor', get(fig, 'Color'), ...
    'HorizontalAlignment', 'left');

uicontrol(fig, 'Style', 'pushbutton', 'Units', 'normalized', ...
    'Position', [0.03 0.79 0.25 0.07], ...
    'String', 'Load Image...', ...
    'FontSize', 11, ...
    'Callback', @loadImage);

analyzeButton = uicontrol(fig, 'Style', 'pushbutton', ...
    'Units', 'normalized', 'Position', [0.03 0.69 0.25 0.07], ...
    'String', 'Analyze Shapes', 'FontSize', 11, ...
    'Enable', 'off', 'Callback', @analyzeImageCallback);

saveButton = uicontrol(fig, 'Style', 'pushbutton', ...
    'Units', 'normalized', 'Position', [0.03 0.59 0.25 0.07], ...
    'String', 'Save Binary Mask...', 'FontSize', 11, ...
    'Enable', 'off', 'Callback', @saveMask);

graphButton = uicontrol(fig, 'Style', 'pushbutton', ...
    'Units', 'normalized', 'Position', [0.03 0.49 0.25 0.07], ...
    'String', 'Show Results Graph', 'FontSize', 11, ...
    'Enable', 'off', 'Callback', @showResultsGraph);

fileLabel = uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.03 0.42 0.26 0.06], ...
    'String', 'No image loaded', ...
    'BackgroundColor', get(fig, 'Color'), ...
    'HorizontalAlignment', 'left', ...
    'Max', 2);

uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.03 0.35 0.25 0.05], ...
    'String', 'Detected results', 'FontSize', 12, ...
    'FontWeight', 'bold', ...
    'BackgroundColor', get(fig, 'Color'), ...
    'HorizontalAlignment', 'left');

redCountLabel = makeCountLabel(0.29, 'Red Circles: 0');
blueCountLabel = makeCountLabel(0.23, 'Blue Squares: 0');
greenCountLabel = makeCountLabel(0.17, 'Green Triangles: 0');
totalCountLabel = makeCountLabel(0.11, 'Total objects: 0');

statusLabel = uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.03 0.04 0.93 0.06], ...
    'String', 'Load an image to get started.', ...
    'BackgroundColor', get(fig, 'Color'), ...
    'HorizontalAlignment', 'left');

imageData = [];
sourceFile = '';
analysis = [];

    function label = makeCountLabel(y, text)
        label = uicontrol(fig, 'Style', 'text', 'Units', 'normalized', ...
            'Position', [0.03 y 0.26 0.05], ...
            'String', text, ...
            'BackgroundColor', get(fig, 'Color'), ...
            'HorizontalAlignment', 'left', ...
            'FontSize', 11);
    end

    function loadImage(~, ~)
        [file, path] = uigetfile( ...
            {'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff', 'Image files'; ...
             '*.*', 'All files'}, ...
            'Select an image');
        if isequal(file, 0)
            return;
        end

        try
            [loadedImage, colorMap] = imread(fullfile(path, file));
            if ~isempty(colorMap)
                loadedImage = ind2rgb(loadedImage, colorMap);
            end
            if ndims(loadedImage) == 2
                loadedImage = repmat(loadedImage, [1 1 3]);
            elseif size(loadedImage, 3) ~= 3
                error('The selected image must be grayscale or RGB.');
            end
        catch exception
            errordlg(exception.message, 'Could Not Load Image', 'modal');
            return;
        end

        imageData = loadedImage;
        sourceFile = fullfile(path, file);
        analysis = [];
        imshow(imageData, 'Parent', axOriginal);
        title(axOriginal, 'Original Image');
        cla(axMask);
        title(axMask, 'Processed Binary Mask');
        axis(axMask, 'off');
        fileLabel.String = file;
        analyzeButton.Enable = 'on';
        saveButton.Enable = 'off';
        graphButton.Enable = 'off';
        redCountLabel.String = 'Red Circles: 0';
        blueCountLabel.String = 'Blue Squares: 0';
        greenCountLabel.String = 'Green Triangles: 0';
        totalCountLabel.String = 'Total objects: 0';
        statusLabel.String = 'Image loaded. Select Analyze Shapes to begin.';
    end

    function analyzeImageCallback(~, ~)
        if isempty(imageData)
            return;
        end

        fig.Pointer = 'watch';
        statusLabel.String = 'Analyzing image...';
        drawnow;
        try
            analysis = analyzeShapes(imageData);
            imshow(analysis.mask, 'Parent', axMask);
            title(axMask, 'Processed Binary Mask');
            redCountLabel.String = sprintf('Red Circles: %d', ...
                analysis.redCircles);
            blueCountLabel.String = sprintf('Blue Squares: %d', ...
                analysis.blueSquares);
            greenCountLabel.String = sprintf('Green Triangles: %d', ...
                analysis.greenTriangles);
            totalCountLabel.String = sprintf('Total objects: %d', ...
                analysis.totalObjects);
            saveButton.Enable = 'on';
            graphButton.Enable = 'on';
            statusLabel.String = sprintf('Analysis complete: %d object(s) detected.', ...
                analysis.totalObjects);
        catch exception
            analysis = [];
            saveButton.Enable = 'off';
            graphButton.Enable = 'off';
            statusLabel.String = 'Analysis failed.';
            errordlg(exception.message, 'Analysis Error', 'modal');
        end
        fig.Pointer = 'arrow';
    end

    function saveMask(~, ~)
        if isempty(analysis)
            return;
        end
        [file, path] = uiputfile('Binary_Mask.png', ...
            'Save Processed Binary Mask');
        if isequal(file, 0)
            return;
        end
        try
            imwrite(analysis.mask, fullfile(path, file));
            statusLabel.String = sprintf('Binary mask saved to %s', ...
                fullfile(path, file));
        catch exception
            errordlg(exception.message, 'Could Not Save Image', 'modal');
        end
    end

    function showResultsGraph(~, ~)
        if isempty(analysis)
            return;
        end
        PlotShapeResults(analysis.redCircles, analysis.blueSquares, ...
            analysis.greenTriangles);
    end

    function result = analyzeShapes(inputImage)
        % Detect objects and classify them by bounding-box extent and average color.

        resizedImage = imresize(inputImage, 0.5);
        grayImage = rgb2gray(resizedImage);
        threshold = graythresh(grayImage);
        binaryMask = imbinarize(grayImage, threshold);

        if mean(binaryMask(:)) > 0.5
            binaryMask = ~binaryMask;
        end

        binaryMask = bwareaopen(binaryMask, 500);
        binaryMask = imfill(binaryMask, 'holes');
        [labelsImage, objectCount] = bwlabel(binaryMask, 8);

        result = struct( ...
            'mask', binaryMask, ...
            'totalObjects', objectCount, ...
            'redCircles', 0, ...
            'blueSquares', 0, ...
            'greenTriangles', 0);
        if objectCount == 0
            return;
        end

        rgbImage = double(im2uint8(resizedImage));
        redChannel = rgbImage(:, :, 1);
        greenChannel = rgbImage(:, :, 2);
        blueChannel = rgbImage(:, :, 3);

        [rows, columns] = find(binaryMask);
        objectLabels = labelsImage(binaryMask);
        pixelCounts = accumarray(objectLabels, 1, [objectCount 1]);
        minRows = accumarray(objectLabels, rows, [objectCount 1], @min);
        maxRows = accumarray(objectLabels, rows, [objectCount 1], @max);
        minColumns = accumarray(objectLabels, columns, [objectCount 1], @min);
        maxColumns = accumarray(objectLabels, columns, [objectCount 1], @max);
        boxAreas = (maxRows - minRows + 1) .* (maxColumns - minColumns + 1);
        extents = pixelCounts ./ boxAreas;

        redAverage = accumarray(objectLabels, redChannel(binaryMask), ...
            [objectCount 1], @sum) ./ pixelCounts;
        greenAverage = accumarray(objectLabels, greenChannel(binaryMask), ...
            [objectCount 1], @sum) ./ pixelCounts;
        blueAverage = accumarray(objectLabels, blueChannel(binaryMask), ...
            [objectCount 1], @sum) ./ pixelCounts;

        for k = 1:objectCount
            if extents(k) > 0.85
                shapeType = 'Square';
            elseif extents(k) < 0.65
                shapeType = 'Triangle';
            else
                shapeType = 'Circle';
            end

            colorType = 'Unknown';
            if redAverage(k) > greenAverage(k) + 50 && ...
                    redAverage(k) > blueAverage(k) + 50
                colorType = 'Red';
            elseif blueAverage(k) > redAverage(k) + 50 && ...
                    blueAverage(k) > greenAverage(k) + 50
                colorType = 'Blue';
            elseif greenAverage(k) > redAverage(k) + 50 && ...
                    greenAverage(k) > blueAverage(k) + 50
                colorType = 'Green';
            end

            if strcmp(colorType, 'Red') && strcmp(shapeType, 'Circle')
                result.redCircles = result.redCircles + 1;
            elseif strcmp(colorType, 'Blue') && strcmp(shapeType, 'Square')
                result.blueSquares = result.blueSquares + 1;
            elseif strcmp(colorType, 'Green') && strcmp(shapeType, 'Triangle')
                result.greenTriangles = result.greenTriangles + 1;
            end
        end
    end
end
