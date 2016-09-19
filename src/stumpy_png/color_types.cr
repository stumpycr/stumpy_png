require "stumpy_core"
include StumpyCore

module StumpyPNG
  module ColorTypes
    def self.decode(values, bit_depth, palette, color_type, &block)
      case color_type
      when 0 # Grayscale
        values.each { |gray| yield RGBA.from_gray_n(gray, bit_depth) }
      when 2 # RGB
        values.each_slice(3) { |rgb| yield RGBA.from_rgb_n(rgb, bit_depth) }
      when 3 # Palette
        values.each { |index| yield palette[index] }
      when 4 # GrayscaleAlpha
        values.each_slice(2) { |graya| yield RGBA.from_graya_n(graya, bit_depth) }
      when 6 # RGBAlpha
        values.each_slice(4) { |rgba| yield RGBA.from_rgba_n(rgba, bit_depth) }
      end
    end
  end
end
