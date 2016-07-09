require "./rgba"

module StumpyPNG
  class Canvas
    ALPHA_CHECKERBOARD_SIZE = 8

    getter width : Int32
    getter height : Int32
    getter pixels : Array(RGBA)

    def initialize(@width, @height)
      @pixels = Array.new(@width * @height, RGBA.new(0_u16, 0_u16, 0_u16, 0_u16))
    end

    def set_pixel(x, y, color)
      @pixels[x + @width * y] = color
    end

    def get_pixel(x, y)
      @pixels[x + @width * y]
    end

    def each_column(&block)
      @height.times do |n|
        yield @pixels[n * @width, @width]
      end
    end

    def ==(other)
      self.class == other.class &&
      @width == other.width &&
      @height == other.height &&
      @pixels == other.pixels
    end

    def write_ppm(path)
      File.open(path, "w") do |file|

        # Write ppm header
        file.puts "P3"
        file.puts "#{@width} #{@height}"
        file.puts "255"

        @height.times do |y|
          file.puts (0...@width).map { |x| get_pixel(x, y).to_rgb8.to_a }.flatten.join(" ")
          # @width.times do |x|
            # color = get_pixel(x, y)

            # Checkerboard colors
            # c1 = RGBA.new(25700_u16, 25700_u16, 25700_u16, UInt16::MAX - color.a)
            # c2 = RGBA.new(37008_u16, 37008_u16, 37008_u16, UInt16::MAX - color.a)
            # checkerboard = ((y / ALPHA_CHECKERBOARD_SIZE) + (x / ALPHA_CHECKERBOARD_SIZE)).even? ? c1 : c2

            # Mix current color and checkerboard color
            # pixel = color.add(checkerboard)
            # pixel = color
            # file.print pixel.to_rgb8.join(" ")
          # end
          # file.
        end
      end
    end

    def write_rgba(path)
      File.open(path, "w") do |file|
        @pixels.each do |pixel|
          pixel.to_rgba8.each do |byte|
            file.print byte.chr
            # file.write_byte(byte)
          end
        end
      end
    end
  end
end
