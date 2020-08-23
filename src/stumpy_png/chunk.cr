require "digest/crc32"
require "./utils"

module StumpyPNG
  class Chunk
    property type : String
    property data : Bytes
    property crc : UInt32

    # Parse chunk data **without** size.
    def self.parse(slice : Bytes)
      type = String.new slice[0, 4]
      crc = Utils.bytes_to_uint32(slice[slice.size - 4, 4])
      data = slice[4, slice.size - 8]

      expected_crc = Digest::CRC32.checksum(slice[0, slice.size - 4])
      raise "Incorrect checksum" if crc != expected_crc

      Chunk.new(type, data, crc)
    end

    def initialize(@type, @data, crc : UInt32? = nil)
      if crc
        @crc = crc
      elsif data.empty?
        @crc = Digest::CRC32.checksum(type)
      else
        @crc = Digest::CRC32.update(data, Digest::CRC32.checksum(type))
      end
    end

    def size
      @data.size
    end

    # Returns chunk data **with** size as a `Bytes`.
    def raw : Bytes
      io = IO::Memory.new
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
