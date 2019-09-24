module StumpyPNG
  module Scanline
    # We don't need to care about invalid bit depths here,
    # because they are validated before
    def self.decode_grayscale(scanline, canvas, y, bit_depth)
      case bit_depth
      when  1; Scanline.decode_grayscale_1(scanline, canvas, y)
      when  2; Scanline.decode_grayscale_2(scanline, canvas, y)
      when  4; Scanline.decode_grayscale_4(scanline, canvas, y)
      when  8; Scanline.decode_grayscale_8(scanline, canvas, y)
      when 16; Scanline.decode_grayscale_16(scanline, canvas, y)
      end
    end

    def self.decode_grayscale_alpha(scanline, canvas, y, bit_depth)
      if bit_depth == 8
        Scanline.decode_grayscale_alpha_8(scanline, canvas, y)
      else
        Scanline.decode_grayscale_alpha_16(scanline, canvas, y)
      end
    end

    def self.decode_rgb(scanline, canvas, y, bit_depth)
      if bit_depth == 8
        Scanline.decode_rgb_8(scanline, canvas, y)
      else
        Scanline.decode_rgb_16(scanline, canvas, y)
      end
    end

    def self.decode_rgb_alpha(scanline, canvas, y, bit_depth)
      if bit_depth == 8
        Scanline.decode_rgb_alpha_8(scanline, canvas, y)
      else
        Scanline.decode_rgb_alpha_16(scanline, canvas, y)
      end
    end

    def self.decode_palette(scanline, canvas, y, palette, bit_depth)
      case bit_depth
      when 1; Scanline.decode_palette_1(scanline, canvas, y, palette)
      when 2; Scanline.decode_palette_2(scanline, canvas, y, palette)
      when 4; Scanline.decode_palette_4(scanline, canvas, y, palette)
      when 8; Scanline.decode_palette_8(scanline, canvas, y, palette)
      end
    end

    def self.decode_grayscale_1(scanline, canvas, y)
      (0...canvas.width).step(8).each do |x|
        byte = scanline[x // 8]
        (0...8).each do |x2|
          # Make sure we don't write invalid pixels
          # if the canvas.width is not a multiple of 8
          break if x + x2 >= canvas.width

          gray = (byte >> 7) == 0 ? 0_u16 : 0xffff_u16
          byte <<= 1
          canvas[x + x2, y] = RGBA.new(gray)
        end
      end
    end

    def self.decode_grayscale_2(scanline, canvas, y)
      (0...canvas.width).step(4).each do |x|
        byte = scanline[x // 4]
        (0...4).each do |x2|
          break if x + x2 >= canvas.width

          gray = (byte >> 6).to_u16
          gray += gray << 2
          gray += gray << 4
          gray += gray << 8

          byte <<= 2
          canvas[x + x2, y] = RGBA.new(gray)
        end
      end
    end

    def self.decode_grayscale_4(scanline, canvas, y)
      (0...canvas.width).step(2).each do |x|
        byte = scanline[x // 2]
        (0...2).each do |x2|
          break if x + x2 >= canvas.width

          gray = (byte >> 4).to_u16
          gray += gray << 4
          gray += gray << 8

          byte <<= 4
          canvas[x + x2, y] = RGBA.new(gray)
        end
      end
    end

    def self.decode_grayscale_8(scanline, canvas, y)
      (0...canvas.width).each do |x|
        gray = scanline[x].to_u16
        gray += gray << 8
        canvas[x, y] = RGBA.new(gray)
      end
    end

    def self.decode_grayscale_16(scanline, canvas, y)
      (0...canvas.width).each do |x|
        gray = (scanline[2 * x].to_u16 << 8) + scanline[2 * x + 1]
        canvas[x, y] = RGBA.new(gray)
      end
    end

    def self.decode_grayscale_alpha_8(scanline, canvas, y)
      (0...canvas.width).each do |x|
        start = 2 * x
        gray = scanline[start].to_u16
        gray += gray << 8
        alpha = scanline[start + 1].to_u16
        alpha += alpha << 8

        color = RGBA.new(gray, alpha)
        canvas[x, y] = color
      end
    end

    def self.decode_grayscale_alpha_16(scanline, canvas, y)
      (0...canvas.width).each do |x|
        start = 4 * x
        gray = (scanline[start].to_u16 << 8) + scanline[start + 1]
        alpha = (scanline[start + 2].to_u16 << 8) + scanline[start + 3]
        canvas[x, y] = RGBA.new(gray, alpha)
      end
    end

    def self.decode_rgb_8(scanline, canvas, y)
      (0...canvas.width).each do |x|
        start = x * 3
        red = scanline[start].to_u16
        red += red << 8
        green = scanline[start + 1].to_u16
        green += green << 8
        blue = scanline[start + 2].to_u16
        blue += blue << 8

        canvas[x, y] = RGBA.new(red, green, blue)
      end
    end

    def self.decode_rgb_16(scanline, canvas, y)
      (0...canvas.width).each do |x|
        start = x * 6
        red = (scanline[start].to_u16 << 8) + scanline[start + 1]
        green = (scanline[start + 2].to_u16 << 8) + scanline[start + 3]
        blue = (scanline[start + 4].to_u16 << 8) + scanline[start + 5]

        canvas[x, y] = RGBA.new(red, green, blue)
      end
    end

    def self.decode_rgb_alpha_8(scanline, canvas, y)
      (0...canvas.width).each do |x|
        start = x * 4
        red = (scanline[start].to_u16 << 8) + scanline[start]
        green = (scanline[start + 1].to_u16 << 8) + scanline[start + 1]
        blue = (scanline[start + 2].to_u16 << 8) + scanline[start + 2]
        alpha = (scanline[start + 3].to_u16 << 8) + scanline[start + 3]

        canvas[x, y] = RGBA.new(red, green, blue, alpha)
      end
    end

    def self.decode_rgb_alpha_16(scanline, canvas, y)
      (0...canvas.width).each do |x|
        start = x * 8
        red = (scanline[start].to_u16 << 8) + scanline[start + 1]
        green = (scanline[start + 2].to_u16 << 8) + scanline[start + 3]
        blue = (scanline[start + 4].to_u16 << 8) + scanline[start + 5]
        alpha = (scanline[start + 6].to_u16 << 8) + scanline[start + 7]

        canvas[x, y] = RGBA.new(red, green, blue, alpha)
      end
    end

    def self.decode_palette_1(scanline, canvas, y, palette)
      (0...canvas.width).step(8).each do |x|
        byte = scanline[x // 8]
        (0...8).each do |x2|
          break if x + x2 >= canvas.width

          canvas[x + x2, y] = palette[byte >> 7]
          byte <<= 1
        end
      end
    end

    def self.decode_palette_2(scanline, canvas, y, palette)
      (0...canvas.width).step(4).each do |x|
        byte = scanline[x // 4]
        (0...4).each do |x2|
          break if x + x2 >= canvas.width

          canvas[x + x2, y] = palette[byte >> 6]
          byte <<= 2
        end
      end
    end

    def self.decode_palette_4(scanline, canvas, y, palette)
      (0...canvas.width).step(2).each do |x|
        byte = scanline[x // 2]
        (0...2).each do |x2|
          break if x + x2 >= canvas.width

          canvas[x + x2, y] = palette[byte >> 4]
          byte <<= 4
        end
      end
    end

    def self.decode_palette_8(scanline, canvas, y, palette)
      (0...canvas.width).each do |x|
        byte = scanline[x]
        canvas[x, y] = palette[byte]
      end
    end
  end
end
