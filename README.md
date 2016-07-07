# stumpy_png

## Classes

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

* `StumpyPNG::PNG`
  * `StumpyPNG::PNG.read(path)` read a png image file
  * `png.to_canvas` convert to a canvas object

## Usage

``` crystal
require "stumpy_png"

png = StumpyPNG::PNG.read("foo.png")
canvas = png.to_canvas

r, g, b = canvas.get_pixel(0, 0).to_rgb8

puts "red=#{r}, green=#{g}, blue=#{b}"
```

## Progress

- [ ] CRC verification

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
- [ ] Adam7

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
