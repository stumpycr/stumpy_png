require "./rgba"

module StumpyPNG
  module ColorTypes
    class Grayscale
      def self.each_pixel(values, bit_depth, palette, &block)
        values.each { |gray| yield RGBA.from_gray_n(gray, bit_depth) }
      end
    end

    class RGB
      def self.each_pixel(values, bit_depth, palette, &block)
        values.each_slice(3) { |rgb| yield RGBA.from_rgb_n(rgb, bit_depth) }
      end
    end

    class Palette
      def self.each_pixel(values, bit_depth, palette, &block)
        values.each { |index| yield palette[index] }
      end
    end

    class GrayscaleAlpha
      def self.each_pixel(values, bit_depth, palette, &block)
        values.each_slice(2) { |graya| yield RGBA.from_graya_n(graya, bit_depth) }
      end
    end

    class RGBAlpha
      def self.each_pixel(values, bit_depth, palette, &block)
        values.each_slice(4) { |rgba| yield RGBA.from_rgba_n(rgba, bit_depth) }
      end
    end
  end
end
