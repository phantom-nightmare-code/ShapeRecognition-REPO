function PlotShapeResults(redCircles, blueSquares, greenTriangles)
% Display recognized shape counts in a bar graph.

counts = [redCircles, blueSquares, greenTriangles];
labels = {'Red Circles', 'Blue Squares', 'Green Triangles'};
barColors = [0.90 0.16 0.16; ...
             0.16 0.38 0.82; ...
             0.18 0.65 0.25];

figure('Name', 'Shape Recognition Results', 'NumberTitle', 'off', ...
    'Color', 'white');
bars = bar(counts, 'FaceColor', 'flat');
bars.CData = barColors;

ax = gca;
ax.XTick = 1:3;
ax.XTickLabel = labels;
ax.FontSize = 10;
ylabel('Number of shapes');
title('Recognized Shape Counts');
grid on;

largestCount = max(counts);
ylim([0 max(1, largestCount + 1)]);
for k = 1:numel(counts)
    text(k, counts(k), sprintf('%d', counts(k)), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom');
end
end
