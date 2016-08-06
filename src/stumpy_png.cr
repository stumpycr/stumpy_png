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

    ihdr_data = [] of UInt8
    ihdr_data.concat Utils.uint32_to_bytes(canvas.width)
    ihdr_data.concat Utils.uint32_to_bytes(canvas.height)
    # bit depth = 16 bit, color_type = rgba, compression = filter = interlacing = none
    ihdr_data.concat({16_u8, 6_u8, 0_u8, 0_u8, 0_u8})

    datastream.chunks << Chunk.new("IHDR", ihdr_data)

    buffer = MemoryIO.new

    canvas.each_column do |col|
      buffer.write_byte(0_u8) # filter = none
      col.each do |pixel|
        {pixel.r, pixel.g, pixel.b, pixel.a}.each do |value|
          Utils.uint16_to_bytes(value).each do |byte|
            buffer.write_byte(byte)
          end
        end
      end
    end

    # Reset buffer position
    buffer.pos = 0
    compressed = MemoryIO.new
    Zlib::Deflate.new(compressed) do |deflate|
      IO.copy(buffer, deflate)
    end
    compressed.pos = 0

    datastream.chunks << Chunk.new("IDAT", compressed.gets_to_end.bytes)
    datastream.chunks << Chunk.new("IEND", [] of UInt8)
    datastream.write(path)
  end
end
