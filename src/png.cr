require "zlib"
require "./rgba"
require "./canvas"
require "./utils"

module StumpyPNG
  class PNG
    HEADER = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]

    # { name, valid bit depths, "fields" per pixel }
    COLOR_TYPES = {
      0 => { :grayscale, [1, 2, 4, 8, 16], 1 },
      2 => { :rgb, [8, 16], 3 },
      3 => { :palette, [1, 2, 4, 8], 1 },
      4 => { :grayscale_alpha, [8, 16], 2 },
      6 => { :rgb_alpha, [8, 16], 4 },
    }

    INTERLACE_METHODS = {
      0 => :no_interlace,
      1 => :adam7,
    }

    FILTER_TYPES = {
      0 => :none,
      1 => :sub,
      2 => :up,
      3 => :average,
      4 => :paeth,
    }

    property width : Int32, height : Int32
    property bit_depth, color_type, compression_method, filter_method, interlace_method, palette
    getter parsed, data

    def initialize
      @width = 0
      @height = 0

      @bit_depth = 0_u8
      @color_type = 0_u8

      @compression_method = 0_u8
      @filter_method = 0_u8
      @interlace_method = 0_u8

      @palette = [] of RGBA
      @idat_buffer = MemoryIO.new
      @parsed = false

      @data = [] of UInt8
    end

    def parse_chunk(chunk)
      type = chunk.shift(4).map(&.chr).join("")
      crc = chunk.pop(4)

      # TODO: verify crc

      case type
      when "IHDR"
        parse_IHDR(chunk)
      when "PLTE"
        parse_PLTE(chunk)
      when "IDAT"
        parse_IDAT(chunk)
      when "IEND"
        parse_IEND(chunk)
      end
    end

    def parse_IEND(chunk)
      # Reset buffer position
      @idat_buffer.pos = 0

      contents = Zlib::Inflate.new(@idat_buffer) do |inflate|
        inflate.gets_to_end
      end
      @data = contents.bytes


      parsed = true
    end

    def parse_IDAT(chunk)
      # Add chunk data to buffer
      chunk.each do |byte|
        @idat_buffer.write_byte(byte)
      end
    end

    def parse_PLTE(chunk)
      "Invalid palette length" unless (chunk.size % 3) == 0
      @palette = chunk.each_slice(3).map { |rgb| RGBA.from_rgb_n(rgb, 8) }.to_a
      # puts "  Parsed palette of size #{@palette.size}"
      # p @palette
    end

    def parse_IHDR(chunk)
      @width              = Utils.parse_integer(chunk.shift(4))
      @height             = Utils.parse_integer(chunk.shift(4))

      @bit_depth          = chunk.shift(1).first
      @color_type         = chunk.shift(1).first
      raise "Invalid color type" unless COLOR_TYPES.has_key?(@color_type)
      unless COLOR_TYPES[@color_type][1].includes?(@bit_depth)
        raise "Invalid bit depth for this color type" 
      end

      @compression_method = chunk.shift(1).first
      raise "Invalid compression method" unless compression_method == 0

      @filter_method      = chunk.shift(1).first
      raise "Invalid filter method" unless filter_method == 0

      @interlace_method   = chunk.shift(1).first
      unless INTERLACE_METHODS.has_key?(interlace_method)
        raise "Invalid interlace method" 
      end

      # puts "  Size: #{@width}x#{@height}px"
      # puts "  Bit Depth: #{@bit_depth}"
      # puts "  Color Type: #{@color_type}"
      # puts "  Compression Method: #{@compression_method}"
      # puts "  Filter Method: #{@filter_method}"
      # puts "  Interlace Method: #{@interlace_method}"
    end

    def to_canvas
      canvas = Canvas.new(@width, @height)
      # puts "  Data size: #{@data.size}b"

      bpp = ([8, @bit_depth].max / 8 * COLOR_TYPES[@color_type][2]).to_i32
      scanline_width = (@bit_depth.to_f / 8 * COLOR_TYPES[@color_type][2] * @width).ceil.to_i32
      # puts "  Bytes per pixel: #{bpp}"
      # puts "  Scanline width: #{scanline_width}"

      prior_scanline = [] of UInt8

      @height.times do |y|
        filter = @data.shift(1).first

        # bytes per pixel
        scanline = @data.shift(scanline_width)
        decoded = [] of UInt8

        case filter
        when 0
          decoded = scanline
        when 1 # sub
          scanline.each_with_index do |byte, index|
            prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]

            decoded << byte + prior
          end
        when 2 # up
          scanline.each_with_index do |byte, index|
            above = (y == 0) ? 0 : prior_scanline[index]

            decoded << byte + above
          end
        when 3 # average
          scanline.each_with_index do |byte, index|
            prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
            above = (y == 0) ? 0 : prior_scanline[index]

            decoded << byte + ((prior.to_f + above.to_f) / 2).floor.to_u8
          end
        when 4 # paeth
          scanline.each_with_index do |byte, index|
            prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
            above = y == 0 ? 0 : prior_scanline[index]
            upper_left = (y == 0 || (index - bpp) < 0) ? 0 : prior_scanline[index - bpp]

            decoded << (byte.to_u16 + Utils.paeth_predictor(prior, above, upper_left)).to_u8
          end
        else
          raise "Unknown filter type #{filter}"
        end

        prior_scanline = decoded

        x = 0
        case @color_type
        when 0 # grayscale
          case @bit_depth
            when 1, 2, 4
              decoded.each_slice(bpp) do |bytes|
                Utils.each_n_bit_integer(bytes.first, @bit_depth) do |value|
                  canvas.set_pixel(x, y, RGBA.from_gray_n(value, @bit_depth))
                  x += 1
                end
              end
            when 8
              decoded.each_slice(bpp) do |gray|
                value = Utils.parse_integer(gray)
                canvas.set_pixel(x, y, RGBA.from_gray_n(value, 8))
                x += 1
              end
            when 16
              decoded.each_slice(bpp) do |gray|
                value = Utils.parse_integer(gray)
                canvas.set_pixel(x, y, RGBA.from_gray_n(value, 16))
                x += 1
              end
            else
              "Invalid bit depth #{bit_depth}"
          end
        when 2 # rgb
          case @bit_depth
            when 8
              decoded.each_slice(bpp) do |values|
                canvas.set_pixel(x, y, RGBA.from_rgb_n(values, 8))
                x += 1
              end
            when 16
              decoded.each_slice(bpp) do |values|
                values = values.each_slice(2).map { |s| Utils.parse_integer(s) }.to_a
                canvas.set_pixel(x, y, RGBA.from_rgb_n(values, 16))
                x += 1
              end
            else
              "Invalid bit depth #{bit_depth}"
          end
        when 3 # palette
          case @bit_depth
            when 1, 2, 4
              decoded.each_slice(bpp) do |bytes|
                Utils.each_n_bit_integer(bytes.first, @bit_depth) do |index|
                  canvas.set_pixel(x, y, @palette[index])
                  x += 1
                end
              end
            when 8
              decoded.each_slice(bpp) do |bytes|
                index = Utils.parse_integer(bytes)
                canvas.set_pixel(x, y, @palette[index])
                x += 1
              end
            else
              "Invalid bit depth #{bit_depth}"
          end
        when 4 # grayscale alpha
          case @bit_depth
            when 8
              decoded.each_slice(bpp) do |values|
                canvas.set_pixel(x, y, RGBA.from_graya_n(values, 8))
                x += 1
              end
            when 16
              decoded.each_slice(bpp) do |values|
                values = values.each_slice(2).map { |s| Utils.parse_integer(s) }.to_a
                canvas.set_pixel(x, y, RGBA.from_graya_n(values, 16))
                x += 1
              end
            else
              "Invalid bit depth #{bit_depth}"
          end
        when 6 # rgb alpha
          case @bit_depth
            when 8
              decoded.each_slice(bpp) do |values|
                canvas.set_pixel(x, y, RGBA.from_rgba_n(values, 8))
                x += 1
              end
            when 16
              decoded.each_slice(bpp) do |values|
                values = values.each_slice(2).map { |s| Utils.parse_integer(s) }.to_a
                canvas.set_pixel(x, y, RGBA.from_rgba_n(values, 16))
                x += 1
              end
            else
              "Invalid bit depth #{bit_depth}"
          end
        else
          raise "Unknown color type #{@color_type}"
        end
      end

      canvas
    end

    def self.read(path)
      png = PNG.new

      File.open(path) do |file|
        raise "Not a png file" if Utils.read_n_byte(file, HEADER.size) != HEADER
        until file.pos == file.size
          chunk_length = Utils.parse_integer(Utils.read_n_byte(file, 4))
          chunk = Utils.read_n_byte(file, chunk_length + 4 + 4)
          png.parse_chunk(chunk)
        end
      end

      png
    end
  end
end
