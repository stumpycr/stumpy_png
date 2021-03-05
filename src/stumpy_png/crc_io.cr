require "digest/crc32"

class CrcIO < IO
  getter crc : UInt32
  property size

  def initialize
    @crc = 0_u32
    @size = 0
  end

  def read(slice : Bytes)
    0
  end

  def write(slice : Bytes) : Nil
    @crc = ::Digest::CRC32.update(slice, @crc)
    @size += slice.size
  end

  def reset
    @crc = 0_u32
  end
end
