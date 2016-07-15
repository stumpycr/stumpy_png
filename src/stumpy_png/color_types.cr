require "./rgba"

module StumpyPNG
  module ColorTypes
    class Grayscale
      include Enumerable(RGBA)

      def self.each_pixel(decoded, bit_depth, palette, &block)
        values = Utils::NBitEnumerable.new(decoded, bit_depth)
        values.each do |gray|
          yield RGBA.from_gray_n(gray, bit_depth)
        end
      end
    end

    class RGB
      def self.each_pixel(decoded, bit_depth, palette, &block)
        values = Utils::NBitEnumerable.new(decoded, bit_depth)
        values.each_slice(3) do |rgb|
          yield RGBA.from_rgb_n(rgb, bit_depth)
        end
      end
    end

    class Palette
      def self.each_pixel(decoded, bit_depth, palette, &block)
        values = Utils::NBitEnumerable.new(decoded, bit_depth)
        values.each do |index|
          yield palette[index]
        end
      end
    end

    class GrayscaleAlpha
      def self.each_pixel(decoded, bit_depth, palette, &block)
        values = Utils::NBitEnumerable.new(decoded, bit_depth)
        values.each_slice(2) do |graya|
          yield RGBA.from_graya_n(graya, bit_depth)
        end
      end
    end

    class RGBAlpha
      def self.each_pixel(decoded, bit_depth, palette, &block)
        values = Utils::NBitEnumerable.new(decoded, bit_depth)
        values.each_slice(4) do |rgba|
          yield RGBA.from_rgba_n(rgba, bit_depth)
        end
      end
    end
  end
end
