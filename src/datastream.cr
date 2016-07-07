require "./utils"

module StumpyPNG
  class Chunk
    property type : String
    property data : Array(UInt8)

    def initialize(chunk)
      @type = chunk.shift(4).map(&.chr).join("")
      crc = chunk.pop(4)
      # TODO: verify crc

      @data = chunk
    end
  end

  class Datastream
    property chunks : Array(Chunk)

    def initialize
      @chunks = [] of Chunk
    end

    def self.read(path)
      datastream = Datastream.new

      File.open(path) do |file|
        unless Utils.read_n_byte(file, 8) == [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]
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
  end
end
