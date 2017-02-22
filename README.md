# stumpy_png
[![Build Status](https://travis-ci.org/l3kn/stumpy_png.svg?branch=master)](https://travis-ci.org/l3kn/stumpy_png)

## Interface

* `StumpyPNG.read(path) : Canvas` read a PNG image file
* `StumpyPNG.write(canvas, path, bit_depth: 16, color_type: :grayscale)` saves a canvas as a PNG image file
  * `bit_depth` is optional, valid values are `8` and `16`(default)
  * `color_type` is optional, valid values are `:grayscale`, `:grayscale_alpha`, `:rgb` and `:rgb_alpha`(default)
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

* RGB with 8 or 16 bits
* RGB + Alpha with 8 or 16 bits
* Grayscale with 8 or 16 bits
* Grayscale + Alpha with 8 or 16 bits

## Contributors

Thanks goes to these wonderful people ([emoji key](https://github.com/kentcdodds/all-contributors#emoji-key)):

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
| [<img src="https://avatars.githubusercontent.com/u/2788811?v=3" width="100px;"/><br /><sub>Chris Hobbs</sub>](http://www.rx14.co.uk)<br /> | [<img src="https://avatars.githubusercontent.com/u/209371?v=3" width="100px;"/><br /><sub>Ary Borenszweig</sub>](http://manas.com.ar)<br /> | [<img src="https://avatars.githubusercontent.com/u/90345?v=3" width="100px;"/><br /><sub>Alex Muscar</sub>](https://github.com/muscar)<br /> |
| :---: | :---: | :---: |
<!-- ALL-CONTRIBUTORS-LIST:END -->

This project follows the [all-contributors](https://github.com/kentcdodds/all-contributors) specification. Contributions of any kind welcome!
