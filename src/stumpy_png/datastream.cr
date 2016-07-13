require "zlib"
require "./utils"
require "./chunk"

module StumpyPNG
  class Datastream
    property chunks : Array(Chunk)

    HEADER = 0x89504e470d0a1a0a

    def initialize
      @chunks = [] of Chunk
    end

    def self.read(path)
      datastream = Datastream.new

      File.open(path) do |file|
        unless file.read_bytes(UInt64, IO::ByteFormat::BigEndian) == HEADER
          raise "Not a png file"
        end

        until file.pos == file.size
          chunk_length = file.read_bytes(UInt32, IO::ByteFormat::BigEndian)
          chunk = Utils.read_n_byte(file, chunk_length + 4 + 4)
          datastream.chunks << Chunk.new(chunk)
        end
      end

      datastream
    end

    def raw
      bytes = [] of UInt8

      @chunks.each do |chunk|
        # [chunk length][chunk raw = type, data, crc]
        bytes += Utils.uint32_to_bytes(chunk.size)
        bytes += chunk.raw
      end

      bytes
    end

    def write(path)
      File.open(path, "w") do |file|
        file.write_bytes(HEADER, IO::ByteFormat::BigEndian)
        raw.each do |byte|
          file.write_byte(byte)
        end
      end
    end
  end
end
