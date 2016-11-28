module StumpyPNG
  module ColorTypes
    def self.decode(values, bit_depth, palette, color_type, &block)
      case color_type
      when 0 # Grayscale
        values.each { |gray| yield RGBA.from_gray_n(gray, bit_depth) }
      when 2 # RGB
        decode2(values, bit_depth, palette) do |pixel|
          yield pixel
        end
      when 3 # Palette
        values.each { |index| yield palette[index] }
      when 4 # GrayscaleAlpha
        decode4(values, bit_depth, palette) do |pixel|
          yield pixel
        end
      when 6 # RGBAlpha
        decode6(values, bit_depth, palette) do |pixel|
          yield pixel
        end
      end
    end

    private def self.decode2(values, bit_depth, palette, &block)
      buf = uninitialized UInt16[3]
      i = 0
      values.each do |value|
        buf[i] = value
        i += 1
        if i == 3
          yield RGBA.from_rgb_n(buf, bit_depth)
          i = 0
        end
      end
    end

    private def self.decode4(values, bit_depth, palette, &block)
      buf = uninitialized UInt16[2]
      i = 0
      values.each do |value|
        buf[i] = value
        i += 1
        if i == 2
          yield RGBA.from_graya_n(buf, bit_depth)
          i = 0
        end
      end
    end

    private def self.decode6(values, bit_depth, palette, &block)
      buf = uninitialized UInt16[4]
      i = 0
      values.each do |value|
        buf[i] = value
        i += 1
        if i == 4
          yield RGBA.from_rgba_n(buf.to_slice, bit_depth)
          i = 0
        end
      end
    end
  end
end
