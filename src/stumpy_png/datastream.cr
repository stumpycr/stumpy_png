require "compress/zlib"
require "./utils"
require "./chunk"

module StumpyPNG
  class Datastream
    property chunks : Array(Chunk)

    def initialize(@chunks = [] of Chunk)
    end

    def self.read(path)
      File.open(path) do |file|
        read(file)
      end
    end

    def self.read(io : IO)
      raise "Not a png file" unless io.read_bytes(UInt64, IO::ByteFormat::BigEndian) == StumpyPNG::HEADER

      chunks = [] of Chunk

      loop do
        begin
          chunk_length = io.read_bytes(UInt32, IO::ByteFormat::BigEndian)
        rescue IO::EOFError
          break
        end

        chunk_data = Bytes.new(chunk_length + 4 + 4)
        io.read_fully(chunk_data)

        chunks << Chunk.parse(chunk_data)
      end

      Datastream.new chunks
    end

    def raw : Bytes
      io = IO::Memory.new
      write(io)
      io.to_slice
    end

    def write(path : String)
      File.open(path, "w") do |file|
        write(file)
      end
    end

    def write(io : IO)
      io.write_bytes(StumpyPNG::HEADER, IO::ByteFormat::BigEndian)
      @chunks.each do |chunk|
        chunk.write(io)
      end
    end
  end
end
