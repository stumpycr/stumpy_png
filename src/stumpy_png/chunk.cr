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

      if data.empty?
        @crc = Zlib.crc32(s1).to_u32
      else
        @crc = Zlib.crc32(s2, Zlib.crc32(s1)).to_u32
      end
    end

    def size
      @data.size
    end

    def raw : Array(UInt8)
      @type.chars.map { |c| c.ord.to_u8 } + @data + Utils.uint32_to_bytes(@crc)
    end
  end
end
