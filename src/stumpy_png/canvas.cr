require "./rgba"

module StumpyPNG
  class Canvas
    getter width : Int32
    getter height : Int32
    getter pixels : Slice(RGBA)

    def initialize(@width, @height, background = RGBA.new(0_u16, 0_u16, 0_u16, 0_u16))
      @pixels = Slice.new(@width * @height, background)
    end

    def set_pixel(x, y, color)
      @pixels[x + @width * y] = color
    end

    def get_pixel(x, y)
      @pixels[x + @width * y]
    end

    def includes_pixel?(x, y)
      0 <= x && x < @width && 0 <= y && y < @height
    end

    def each_column(&block)
      @height.times do |n|
        yield @pixels[n * @width, @width]
      end
    end

    def rotate
      rotated = Canvas.new(@height, @width)

      (0...@width).each do |x|
        (0...@height).each do |y|
          rotated.set_pixel(y, x, get_pixel(x, y))
        end
      end

      rotated
    end

    def crop_y(from, to)
      if from >= to || from < 0 || to > @height
        raise "Invalid y range #{from}-#{to}"
      end

      cropped = Canvas.new(@width, to - from)

      (0...@width).each do |x|
        (from...to).each do |y|
          pixel = get_pixel(x, y)
          cropped.set_pixel(x, y-from, pixel)
        end
      end

      cropped
    end

    def ==(other)
      self.class == other.class &&
      @width == other.width &&
      @height == other.height &&
      @pixels == other.pixels
    end
  end
end
