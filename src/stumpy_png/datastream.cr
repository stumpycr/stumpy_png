require "zlib"
require "./utils"
require "./chunk"

module StumpyPNG
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
