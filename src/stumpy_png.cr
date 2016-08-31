require "zlib"
require "./stumpy_png/png"

module StumpyPNG
  def self.read(path)
    png = PNG.new

    Datastream.read(path).chunks.each do |chunk|
      png.parse_chunk(chunk)
    end

    png.canvas
  end

  def self.write(canvas, path)
    datastream = Datastream.new

    ihdr_io = MemoryIO.new(13)
    ihdr_io.write_bytes(canvas.width, IO::ByteFormat::BigEndian)
    ihdr_io.write_bytes(canvas.height, IO::ByteFormat::BigEndian)
    ihdr_io.write_byte 16_u8 # bit depth = 16 bit
    ihdr_io.write_byte 6_u8 # color_type = rgba
    ihdr_io.write_byte 0_u8 # compression = deflate
    ihdr_io.write_byte 0_u8 # filter = adaptive
    ihdr_io.write_byte 0_u8 # interlacing = none

    datastream.chunks << Chunk.new("IHDR", ihdr_io.to_slice)

    buffer = MemoryIO.new

    canvas.each_column do |col|
      buffer.write_byte(0_u8) # filter = none
      col.each do |pixel|
        {pixel.r, pixel.g, pixel.b, pixel.a}.each do |value|
          buffer.write_bytes(value, IO::ByteFormat::BigEndian)
        end
      end
    end

    # Reset buffer position
    buffer.pos = 0

    compressed = MemoryIO.new
    Zlib::Deflate.new(compressed) do |deflate|
      IO.copy(buffer, deflate)
    end

    datastream.chunks << Chunk.new("IDAT", compressed.to_slice)
    datastream.chunks << Chunk.new("IEND", Slice(UInt8).new(0))
    datastream.write(path)
  end
end
