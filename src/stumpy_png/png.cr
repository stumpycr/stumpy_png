require "./utils"
require "./datastream"
require "./filters"
require "./scanline"

module StumpyPNG
  class PNG
    # { name, valid bit depths, "fields" per pixel }
    COLOR_TYPES = {
      0 => {:grayscale, {1, 2, 4, 8, 16}, 1},
      2 => {:rgb, {8, 16}, 3},
      3 => {:palette, {1, 2, 4, 8}, 1},
      4 => {:grayscale_alpha, {8, 16}, 2},
      6 => {:rgb_alpha, {8, 16}, 4},
    }

    INTERLACE_METHODS = {
      0 => :no_interlace,
      1 => :adam7,
    }

    getter width = 0_i32
    getter height = 0_i32
    getter bit_depth = 0_u8
    getter color_type = 0_u8
    getter compression_method = 0_u8
    getter filter_method = 0_u8
    getter interlace_method = 0_u8
    getter palette = [] of RGBA
    getter? parsed = false
    getter data = Bytes.new(0)
    getter canvas = Canvas.new(0, 0)

    def initialize
      @idat_buffer = IO::Memory.new
      @idat_count = 0
    end

    def parse_iend(chunk : Chunk)
      raise "Missing IDAT chunk" if @idat_count == 0

      # Reset buffer position
      @idat_buffer.pos = 0

      Compress::Zlib::Reader.open(@idat_buffer) do |inflate|
        io = IO::Memory.new
        IO.copy(inflate, io)
        @data = io.to_slice
      end

      @parsed = true

      if @interlace_method == 0
        @canvas = to_canvas_none
      else
        @canvas = to_canvas_adam7
      end
    end

    def parse_idat(chunk : Chunk)
      @idat_count += 1
      @idat_buffer.write(chunk.data)
    end

    def parse_plte(chunk : Chunk)
      raise "Invalid palette length" unless (chunk.size % 3) == 0
      @palette = chunk.data.each_slice(3).map { |rgb| RGBA.from_rgb_n(rgb, 8) }.to_a
    end

    def parse_ihdr(chunk : Chunk)
      @width = Utils.parse_integer(chunk.data[0, 4])
      @height = Utils.parse_integer(chunk.data[4, 4])

      @color_type = chunk.data[9]
      color_type = COLOR_TYPES[@color_type]?
      color_type ||
        raise "Invalid color type"

      @bit_depth = chunk.data[8]
      @bit_depth.in?(color_type[1]) ||
        raise "Invalid bit depth for this color type"

      @compression_method = chunk.data[10]
      compression_method.zero? ||
        raise "Invalid compression method"

      @filter_method = chunk.data[11]
      filter_method.zero? ||
        raise "Invalid filter method"

      @interlace_method = chunk.data[12]
      INTERLACE_METHODS.has_key?(interlace_method) ||
        raise "Invalid interlace method"
    end

    def to_canvas_none
      canvas = Canvas.new(@width, @height)

      bpp = (@bit_depth.clamp(8..) / 8 * COLOR_TYPES[@color_type][2]).to_i32
      scanline_width = (@bit_depth.to_f / 8 * COLOR_TYPES[@color_type][2] * @width).ceil.to_i32
      prior_scanline = nil
      decoded = Bytes.new(scanline_width)

      data_pos = 0
      @height.times do |y|
        filter = @data[data_pos]

        scanline = @data[data_pos + 1, scanline_width]
        decoded = Filter.apply(scanline, prior_scanline, decoded, bpp, filter)

        data_pos += scanline_width + 1

        case color_type
        when 0 then Scanline.decode_grayscale(decoded, canvas, y, bit_depth)
        when 4 then Scanline.decode_grayscale_alpha(decoded, canvas, y, bit_depth)
        when 2 then Scanline.decode_rgb(decoded, canvas, y, bit_depth)
        when 6 then Scanline.decode_rgb_alpha(decoded, canvas, y, bit_depth)
        when 3 then Scanline.decode_palette(decoded, canvas, y, palette, bit_depth)
        end

        if prior_scanline
          prior_scanline, decoded = decoded, prior_scanline
        else
          prior_scanline = decoded
          decoded = Bytes.new(scanline_width)
        end
      end

      canvas
    end

    def to_canvas_adam7
      starting_row = {0, 0, 4, 0, 2, 0, 1}
      starting_col = {0, 4, 0, 2, 0, 1, 0}
      row_increment = {8, 8, 8, 4, 4, 2, 2}
      col_increment = {8, 8, 4, 4, 2, 2, 1}

      pass = 0
      row = 0
      col = 0
      data_pos = 0

      canvas = Canvas.new(@width, @height)
      bpp = (@bit_depth.clamp(8..) / 8 * COLOR_TYPES[@color_type][2]).to_i32

      while pass < 7
        prior_scanline = nil
        row = starting_row[pass]

        scanline_width_ = ((@width - starting_col[pass]).to_f / col_increment[pass]).ceil.clamp(0..)
        scanline_width = (@bit_depth.to_f / 8 * COLOR_TYPES[@color_type][2] * scanline_width_).ceil.to_i32

        if scanline_width_ == 0
          pass += 1
          next
        end

        decoded = Bytes.new(scanline_width)

        while row < @height
          filter = @data[data_pos]

          scanline = @data[data_pos + 1, scanline_width]
          decoded = Filter.apply(scanline, prior_scanline, decoded, bpp, filter)

          data_pos += scanline_width + 1

          # TODO: This is definitely not the best way to do this
          # because so many intermediate canvases are created.
          # (Should not matter that much, because adam7 encoded png should be pretty rare)

          col = starting_col[pass]

          line_width = scanline_width_.to_i32
          line_canvas = Canvas.new(line_width, 1)

          case color_type
          when 0 then Scanline.decode_grayscale(decoded, line_canvas, 0, bit_depth)
          when 4 then Scanline.decode_grayscale_alpha(decoded, line_canvas, 0, bit_depth)
          when 2 then Scanline.decode_rgb(decoded, line_canvas, 0, bit_depth)
          when 6 then Scanline.decode_rgb_alpha(decoded, line_canvas, 0, bit_depth)
          when 3 then Scanline.decode_palette(decoded, line_canvas, 0, palette, bit_depth)
          end

          (0...line_width).each do |x|
            canvas[col, row] = line_canvas[x, 0]
            col += col_increment[pass]
          end

          row += row_increment[pass]

          if prior_scanline
            prior_scanline, decoded = decoded, prior_scanline
          else
            prior_scanline = decoded
            decoded = Bytes.new(scanline_width)
          end
        end
        pass += 1
      end

      canvas
    end

    def parse_chunk(chunk)
      case chunk.type
      when "IHDR" then parse_ihdr(chunk)
      when "PLTE" then parse_plte(chunk)
      when "IDAT" then parse_idat(chunk)
      when "IEND" then parse_iend(chunk)
      end
    end
  end
end
