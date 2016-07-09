# stumpy_png

## Interface

* `StumpyPNG.read(path) : Canvas` read a PNG image file
* `StumpyPNG.write(canvas, path)` saves a canvas as a PNG image file

* `StumpyPNG::RGBA`, 16-bit rgba color
  * `rgba.r` red channel
  * `rgba.g` green channel
  * `rgba.b` blue channel
  * `rgba.a` alpha channel
  * `rgba.to_rgba8` returns a tuple of 4 8-bit values `{ r, g, b, a}`
  * `rgba.to_rgb8` returns a tuple of 3 8-bit values  `{ r, g, b }`

* `StumpyPNG::Canvas`, two dimensional Array of RGBA value
  * `canvas.width`
  * `canvas.height`
  * `canvas.set_pixel(x, y)`
  * `canvas.get_pixel(x, y)`

* `StumpyPNG::PNG`, helper class to store some state while parsing PNG files

## Usage

``` crystal
require "stumpy_png"

canvas = StumpyPNG.read("foo.png")
r, g, b = canvas.get_pixel(0, 0).to_rgb8
puts "red=#{r}, green=#{g}, blue=#{b}"
```

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
