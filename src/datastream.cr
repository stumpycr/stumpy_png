require "zlib"
require "./utils"

module StumpyPNG
  class Chunk
    property type : String
    property data : Array(UInt8)
    property crc  : UInt32

    def initialize(raw)
      @type = raw.shift(4).map(&.chr).join("")
      @crc = Utils.bytes_to_uint32(raw.pop(4))
      @data = raw

      s1 = Slice.new(@type.to_unsafe, @type.size)
      s2 = Slice.new(@data.to_unsafe, @data.size)

      expected_crc = Zlib.crc32(s2, Zlib.crc32(s1))

      raise "Incorrect checksum" if crc != expected_crc

    end

    def initialize(@type, @data)
      s1 = Slice.new(@type.to_unsafe, @type.size)
      s2 = Slice.new(@data.to_unsafe, @data.size)

      @crc = Zlib.crc32(s2, Zlib.crc32(s1))
    end

    def size
      @data.size
    end

    def raw : Array(UInt8)
      @type.chars.map { |c| c.ord.to_u8 } + @data + Utils.uint32_to_bytes(@crc)
    end
  end

  class Datastream
    property chunks : Array(Chunk)

    HEADER = [0x89_u8, 0x50_u8, 0x4e_u8, 0x47_u8, 0x0d_u8, 0x0a_u8, 0x1a_u8, 0x0a_u8]

    def initialize
      @chunks = [] of Chunk
    end

    def self.read(path)
      datastream = Datastream.new

      File.open(path) do |file|
        unless Utils.read_n_byte(file, 8) == HEADER
          raise "Not a png file"
        end

        until file.pos == file.size
          chunk_length = Utils.parse_integer(Utils.read_n_byte(file, 4))
          chunk = Utils.read_n_byte(file, chunk_length + 4 + 4)
          datastream.chunks << Chunk.new(chunk)
        end
      end

      datastream
    end

    def raw
      bytes = [] of UInt8
      bytes += HEADER

      @chunks.each do |chunk|
        # [chunk length][chunk raw = type, data, crc]
        bytes += Utils.uint32_to_bytes(chunk.size)
        bytes += chunk.raw
      end

      bytes
    end

    def write(path)
      File.open(path, "w") do |file|
        raw.each do |byte|
          file.write_byte(byte)
        end
      end
    end
  end
end
