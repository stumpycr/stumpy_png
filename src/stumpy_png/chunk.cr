require "./utils"

module StumpyPNG
  class Chunk
    property type : String
    property data : Slice(UInt8)
    property crc : UInt32

    # Parse chunk data **without** size.
    def self.parse(slice : Slice(UInt8))
      type = String.new slice[0, 4]
      crc = Utils.bytes_to_uint32(slice[slice.size - 4, 4])
      data = slice[4, slice.size - 8]

      expected_crc = Zlib.crc32(slice[0, slice.size - 4])
      raise "Incorrect checksum" if crc != expected_crc

      Chunk.new(type, data, crc)
    end

    def initialize(@type, @data, crc : UInt32? = nil)
      if crc
        @crc = crc
      elsif data.empty?
        @crc = Zlib.crc32(type).to_u32
      else
        @crc = Zlib.crc32(data, Zlib.crc32(type)).to_u32
      end
    end

    def size
      @data.size
    end

    # Returns chunk data **with** size as a `Slice(UInt8)`.
    def raw : Slice(UInt8)
      io = MemoryIO.new
      write(io)
      io.to_slice
    end

    # Write chunk data to *io* **with** size.
    def write(io : IO)
      io.write_bytes(size, IO::ByteFormat::BigEndian)
      io << @type
      io.write(@data)
      io.write_bytes(@crc, IO::ByteFormat::BigEndian)
    end
  end
end
