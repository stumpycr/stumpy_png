require "zlib"
require "stumpy_core"
require "./stumpy_png/png"

module StumpyPNG
  include StumpyCore

  def self.read(path)
    png = PNG.new

    Datastream.read(path).chunks.each do |chunk|
      png.parse_chunk(chunk)
    end

    png.canvas
  end

  def self.write(canvas, path)
    datastream = Datastream.new

    ihdr = uninitialized UInt8[13]
    ihdr_slice = ihdr.to_slice
    # TODO: use IO::ByteFormat::BigEndian.encode(canvas.width, ihdr_slice) once 0.20.1 is out
    encode(canvas.width, ihdr_slice)
    encode(canvas.height, ihdr_slice + 4)
    ihdr_slice[8] = 16_u8 # bit depth = 16 bit
    ihdr_slice[9] = 6_u8  # color_type = rgba
    ihdr_slice[10] = 0_u8 # compression = deflate
    ihdr_slice[11] = 0_u8 # filter = adaptive
    ihdr_slice[12] = 0_u8 # interlacing = none

    # datastream.chunks << Chunk.new("IHDR", ihdr_io.to_slice)
    datastream.chunks << Chunk.new("IHDR", ihdr_slice)

    buffer = Bytes.new(canvas.height * (1 + canvas.width * 8))
    buffer_ptr = buffer
    i = 0
    canvas.each_column do |col|
      buffer_ptr += 1
      col.each do |pixel|
        {pixel.r, pixel.g, pixel.b, pixel.a}.each do |value|
          # TODO: use IO::ByteFormat::BigEndian.encode(value, buffer_ptr) once 0.20.1 is out
          encode(value, buffer_ptr)
          buffer_ptr += 2
        end
      end
    end

    compressed = IO::Memory.new
    Zlib::Deflate.new(compressed) do |deflate|
      deflate.write(buffer)
    end

    datastream.chunks << Chunk.new("IDAT", compressed.to_slice)

    datastream.chunks << Chunk.new("IEND", Bytes.new(0))
    datastream.write(path)
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
