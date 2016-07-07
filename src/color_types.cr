require "./rgba"

module StumpyPNG
  module ColorTypes
    class Grayscale
      def each_pixel(decoded, bit_depth, &block)
        case bit_depth
        when 1, 2, 4
          decoded.each do |byte|
            Utils.each_n_bit_integer(byte, bit_depth) do |value|
              yield RGBA.from_gray_n(value, bit_depth)
            end
          end
        when 8
          decoded.each do |byte|
            yield RGBA.from_gray_n(byte, 8)
          end
        when 16
          decoded.each_slice(2) do |bytes|
            value = Utils.parse_integer(bytes)
            yield RGBA.from_gray_n(value, 16)
          end
        else
          "Invalid bit depth #{bit_depth}"
        end
      end
    end

    class RGB
      def each_pixel(decoded, bit_depth, &block)
        case bit_depth
          when 8
            decoded.each_slice(3) do |values|
              yield RGBA.from_rgb_n(values, 8)
            end
          when 16
            decoded.each_slice(6) do |values|
              values = values.each_slice(2).map { |s| Utils.parse_integer(s) }.to_a
              yield RGBA.from_rgb_n(values, 16)
            end
          else
            "Invalid bit depth #{bit_depth}"
        end
      end
    end

    class Palette
      property palette : Array(RGBA)

      def initialize(@palette)
      end

      def each_pixel(decoded, bit_depth, &block)
        case bit_depth
          when 1, 2, 4
            decoded.each do |byte|
              Utils.each_n_bit_integer(byte, bit_depth) do |index|
                yield @palette[index]
              end
            end
          when 8
            decoded.each do |byte|
              yield @palette[byte]
            end
          else
            "Invalid bit depth #{bit_depth}"
        end
      end
    end

    class GrayscaleAlpha
      def each_pixel(decoded, bit_depth, &block)
        case bit_depth
          when 8
            decoded.each_slice(2) do |values|
              yield RGBA.from_graya_n(values, 8)
            end
          when 16
            decoded.each_slice(4) do |values|
              values = values.each_slice(2).map { |s| Utils.parse_integer(s) }.to_a
              yield RGBA.from_graya_n(values, 16)
            end
          else
            "Invalid bit depth #{bit_depth}"
        end
      end
    end

    class RGBAlpha
      def each_pixel(decoded, bit_depth, &block)
        case bit_depth
          when 8
            decoded.each_slice(4) do |values|
              yield RGBA.from_rgba_n(values, 8)
            end
          when 16
            decoded.each_slice(8) do |values|
              values = values.each_slice(2).map { |s| Utils.parse_integer(s) }.to_a
              yield RGBA.from_rgba_n(values, 16)
            end
          else
            "Invalid bit depth #{bit_depth}"
        end
      end
    end

  end
end
