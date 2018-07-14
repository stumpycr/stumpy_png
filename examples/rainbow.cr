require "../src/stumpy_png"
include StumpyPNG

canvas = Canvas.new(256, 256)

(0..255).each do |x|
  (0..255).each do |y|
    # RGBA.from_rgb_n(values, bit_depth) is an internal helper method
    # that creates an RGBA object from a rgb triplet with a given bit depth
    color = RGBA.from_rgb_n(x, y, 255, 8)
    canvas[x, y] = color
  end
end

StumpyPNG.write(canvas, "rainbow.png")
