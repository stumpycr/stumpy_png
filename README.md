# stumpy_png
[![Build Status](https://travis-ci.org/l3kn/stumpy_png.svg?branch=master)](https://travis-ci.org/l3kn/stumpy_png)

## Interface

* `StumpyPNG.read(path) : Canvas` read a PNG image file
* `StumpyPNG.write(canvas, path)` saves a canvas as a PNG image file
* `StumpyPNG::PNG`, helper class to store some state while parsing PNG files
* `Canvas` and `RGBA` from [stumpy_core](https://github.com/l3kn/stumpy_core)

## Usage

### Reading

``` crystal
require "stumpy_png"

canvas = StumpyPNG.read("foo.png")
r, g, b = canvas[0, 0].to_rgb8
puts "red=#{r}, green=#{g}, blue=#{b}"
```

### Writing

``` crystal
include StumpyPNG

canvas = Canvas.new(256, 256)

(0...255).each do |x|
  (0...255).each do |y|
    # RGBA.from_rgb_n(values, bit_depth) is an internal helper method
    # that creates an RGBA object from a rgb triplet with a given bit depth
    color = RGBA.from_rgb_n(x, y, 255, 8)
    canvas[x, y] = color
  end
end

StumpyPNG.write(canvas, "rainbow.png")
```

![PNG image with a color gradient](examples/rainbow.png)

(See `examples/` for more examples)

## Reading PNG files

### Color Types

- [x] Grayscale
- [x] Grayscale + Alpha
- [x] RGB
- [x] RGB + Alpha
- [x] Palette

### Filter Types

- [x] None
- [x] Sub
- [x] Up
- [x] Average
- [x] Paeth

### Interlacing Methods

- [x] None
- [x] Adam7

### Ancillary Chunks

- [ ] tRNS
- [ ] cHRM
- [ ] gAMA
- [ ] iCCP
- [ ] sBIT
- [ ] sRGB
- [ ] tEXt
- [ ] zTXt
- [ ] iTXt
- [ ] bKGD
- [ ] hIST
- [ ] pHYs
- [ ] sPLT
- [ ] tIME

## Writing

Only supports writing to a RGB + Alpha PNG image
without any filters, interlacing or ancillary chunks.
