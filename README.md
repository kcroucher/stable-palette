![](demo.apng)

# What's this?

A method of creating stylized art that conforms to a palette and responds to lighting, running in Godot 4. It can be used for 2D or 3D art, but the demo in this project uses 2D art. It implements the algorithm used by the [LutLight2D](https://github.com/NullTale/LutLight2D) Unity plugin.

# How does it work?

The project expects the user to provide a table contained in the image `ramps.png`. The image is organized as follows: At y=0, every color in the palette is provided as a key. At all successive values of y, the user defines a brightness gradient, starting from the brightest color at y=1, all the way to the darkest color at y=n.

We then generate a lookup table in the `create_lut()` function when the project runs as a texture. The texture is essentially a 4D table with quantized r,g,b, and brightness parameters to some value with a default of 64. Each sub-table contains a gradient of 64 r values in the +x direction and g values in the +y direction. The table is then duplicated in the +x direction 64 times for each value of b, and the number of brightness levels in `ramps.png` in the +y direction for each value of brightness.

Initially, we create a base table with all values of r,g,b corresponding to their position in the table. We then take each value at each brightness level and find the nearest value in the palette when comparing the source color to all palette colors in grayscale. The result is the output `lut.png`, which our fragment shader will check at runtime to determine the color. This ensures we are able to apply lighting and color overlay to a scene, while all colors remain within the palette and change in a way defined by the user, as opposed to the normal way of mixing the light with the underlying texture.

# Running the project

No special setup is needed, just load the project file in the Godot editor and select Run.

There are 3 modes, which you can switch between using the left and right arrow keys:
- Mode 0: No light
- Mode 1: Light applied
- Mode 2: Screen darkened, light applied, mouse controls a point light

# Acknowledgements

Original pixel art created by [Noah Fleming](https://www.cs.mun.ca/~nfleming/).

This project was created at the [Recurse Center](https://www.recurse.com/).
