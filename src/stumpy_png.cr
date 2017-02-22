require "zlib"
require "stumpy_core"
require "./stumpy_png/png"
require "./stumpy_png/crc_io"
require "io/multi_writer"
require "crc32"

module StumpyPNG
  include StumpyCore

  HEADER = 0x89504e470d0a1a0a

  WRITE_BIT_DEPTHS = [8, 16]
  WRITE_COLOR_TYPES = {
    :rgb => 2_u8,
    :rgb_alpha => 6_u8,
    :grayscale => 0_u8, 
    :grayscale_alpha => 4_u8
  }

  def self.read(path)
    png = PNG.new

    Datastream.read(path).chunks.each do |chunk|
      png.parse_chunk(chunk)
    end

    png.canvas
  end

  def self.write(canvas, path, **options)
    bit_depth = options.fetch(:bit_depth, 16)
    color_type = options.fetch(:color_type, :rgb_alpha)

    unless WRITE_BIT_DEPTHS.includes?(bit_depth)
      raise "Invalid bit depth: #{bit_depth}, \
      options: #{WRITE_BIT_DEPTHS.inspect}"
    end

    # Make the compiler happy,
    # if bit_depth were a Symbol, it would already have raised an error before
    return if bit_depth.is_a?(Symbol)

    unless WRITE_COLOR_TYPES.has_key?(color_type)
      raise "Invalid color type: #{color_type}, \
      options: #{WRITE_COLOR_TYPES.keys.inspect}"
    end

    File.open(path, "w") do |file|
      file.write_bytes(HEADER, IO::ByteFormat::BigEndian)

      crc_io = CrcIO.new
      multi = IO::MultiWriter.new(crc_io, file)

      # Write the IHDR chunk
      file.write_bytes(13_u32, IO::ByteFormat::BigEndian)
      multi << "IHDR"

      multi.write_bytes(canvas.width.to_u32, IO::ByteFormat::BigEndian)
      multi.write_bytes(canvas.height.to_u32, IO::ByteFormat::BigEndian)
      multi.write_byte(bit_depth.to_u8)
      multi.write_byte(WRITE_COLOR_TYPES[color_type])
      multi.write_byte(0_u8)  # compression = deflate
      multi.write_byte(0_u8)  # filter = adaptive (only option)
      multi.write_byte(0_u8)  # interlacing = none

      multi.write_bytes(crc_io.crc.to_u32, IO::ByteFormat::BigEndian)
      crc_io.reset

      # Write the IDAT chunk with a dummy chunk size
      file.write_bytes(0_u32, IO::ByteFormat::BigEndian)
      multi << "IDAT"
      crc_io.size = 0

      Zlib::Writer.open(multi) do |deflate|
        case color_type
        when :rgb_alpha; write_rgb_alpha(canvas, deflate, bit_depth)
        when :rgb; write_rgb(canvas, deflate, bit_depth)
        when :grayscale_alpha; write_grayscale_alpha(canvas, deflate, bit_depth)
        when :grayscale; write_grayscale(canvas, deflate, bit_depth)
        end
      end

      # Go back in the file and write the size
      file.seek(-(4 + 4 + crc_io.size), IO::Seek::Current)
      file.write_bytes(crc_io.size.to_u32, IO::ByteFormat::BigEndian)
      file.seek(0, IO::Seek::End)
      multi.write_bytes(crc_io.crc.to_u32, IO::ByteFormat::BigEndian)

      # Write the IEND chunk
      file.write_bytes(0_u32, IO::ByteFormat::BigEndian)
      multi << "IEND"
      multi.write_bytes(CRC32.checksum("IEND"), IO::ByteFormat::BigEndian)
    end
  end

  private def self.write_rgb_alpha(canvas, output, bit_depth)
    if bit_depth == 16
      buffer = Bytes.new(1 + canvas.width * 8)
      canvas.each_column do |col|
        buffer_ptr = buffer + 1 # The first byte is 0 => no filter
        col.each do |pixel|
          {pixel.r, pixel.g, pixel.b, pixel.a}.each do |value|
            # TODO: use IO::ByteFormat::BigEndian.encode(value, buffer_ptr) once 0.20.1 is out
            encode(value, buffer_ptr)
            buffer_ptr += 2
          end
        end
        output.write(buffer)
      end
    else
      buffer = Bytes.new(1 + canvas.width * 4)
      canvas.each_column do |col|
        i = 1
        col.each do |pixel|
          {pixel.r, pixel.g, pixel.b, pixel.a}.each do |value|
            # TODO: use IO::ByteFormat::BigEndian.encode(value, buffer_ptr) once 0.20.1 is out
            buffer[i] = (value >> 8).to_u8
            i += 1
          end
        end
        output.write(buffer)
      end
    end
  end

  private def self.write_rgb(canvas, output, bit_depth)
    if bit_depth == 16
      buffer = Bytes.new(1 + canvas.width * 6)
      canvas.each_column do |col|
        buffer_ptr = buffer + 1 # The first byte is 0 => no filter
        col.each do |pixel|
          {pixel.r, pixel.g, pixel.b}.each do |value|
            # TODO: use IO::ByteFormat::BigEndian.encode(value, buffer_ptr) once 0.20.1 is out
            encode(value, buffer_ptr)
            buffer_ptr += 2
          end
        end
        output.write(buffer)
      end
    else
      buffer = Bytes.new(1 + canvas.width * 3)
      canvas.each_column do |col|
        i = 1
        col.each do |pixel|
          {pixel.r, pixel.g, pixel.b}.each do |value|
            # TODO: use IO::ByteFormat::BigEndian.encode(value, buffer_ptr) once 0.20.1 is out
            buffer[i] = (value >> 8).to_u8
            i += 1
          end
        end
        output.write(buffer)
      end
    end
  end

  private def self.write_grayscale_alpha(canvas, output, bit_depth)
    if bit_depth == 16
      buffer = Bytes.new(1 + canvas.width * 4)
      canvas.each_column do |col|
        buffer_ptr = buffer + 1 # The first byte is 0 => no filter
        col.each do |pixel|
          gray = (pixel.r.to_u32 + pixel.g + pixel.b) / 3
          {gray.to_u16, pixel.a}.each do |value|
            # TODO: use IO::ByteFormat::BigEndian.encode(value, buffer_ptr) once 0.20.1 is out
            encode(value, buffer_ptr)
            buffer_ptr += 2
          end
        end
        output.write(buffer)
      end
    else
      buffer = Bytes.new(1 + canvas.width * 2)
      canvas.each_column do |col|
        i = 1
        col.each do |pixel|
          gray = (pixel.r.to_u32 + pixel.g + pixel.b) / 3
          {gray, pixel.a}.each do |value|
            # TODO: use IO::ByteFormat::BigEndian.encode(value, buffer_ptr) once 0.20.1 is out
            buffer[i] = (value >> 8).to_u8
            i += 1
          end
        end
        output.write(buffer)
      end
    end
  end

  private def self.write_grayscale(canvas, output, bit_depth)
    if bit_depth == 16
      buffer = Bytes.new(1 + canvas.width * 2)
      canvas.each_column do |col|
        buffer_ptr = buffer + 1 # The first byte is 0 => no filter
        col.each do |pixel|
          gray = (pixel.r.to_u32 + pixel.g + pixel.b) / 3
          encode(gray.to_u16, buffer_ptr)
          buffer_ptr += 2
        end
        output.write(buffer)
      end
    else
      buffer = Bytes.new(1 + canvas.width * 1)
      canvas.each_column do |col|
        i = 1
        col.each do |pixel|
          gray = (pixel.r.to_u32 + pixel.g + pixel.b) / 3
          buffer[i] = (gray >> 8).to_u8
          i += 1
        end
        output.write(buffer)
      end
    end
  end

  private def self.encode(value : UInt16, slice)
    bytes = pointerof(value).as(UInt8[2]*).value
    slice[0] = bytes[1]
    slice[1] = bytes[0]
  end

  private def self.encode(value : Int32, slice)
    bytes = pointerof(value).as(UInt8[4]*).value
    slice[0] = bytes[3]
    slice[1] = bytes[2]
    slice[2] = bytes[1]
    slice[3] = bytes[0]
  end
end
