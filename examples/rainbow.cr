require "../src/stumpy_png"

canvas = StumpyCore::Canvas.new(256, 256)

(0...255).each do |x|
  (0...255).each do |y|
    color = StumpyCore::RGBA.from_rgb_n(x, y, 255, 8)
    canvas[x, y] = color
  end
end

StumpyPNG.write(canvas, "rainbow.png")
