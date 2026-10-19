# MATLAB Shape Recognition GUI

An interactive MATLAB GUI that processes an image and counts red circles, blue
squares, and green triangles. It displays the original image beside the
processed binary mask and can plot the recognized counts in a bar chart.

## Requirements

- MATLAB
- Image Processing Toolbox

## Run

1. Open this folder as the MATLAB Current Folder.
2. In the MATLAB Command Window, run:

   ```matlab
   ShapeRecognition
   ```

3. Click **Load Image...**, select an image, and click **Analyze Shapes**.
4. Click **Show Results Graph** to open the optional bar chart.

The included `Shapes.jpg` is a sample input image. The graph can also be run
directly with example counts:

```matlab
PlotShapeResults(2, 1, 3)
```

The shape labels are estimated from binary-mask bounding-box extent, while the
color labels are estimated from average RGB values. Results may vary with
lighting, image background, and object overlap.
