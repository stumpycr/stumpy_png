require "zlib"

class CrcIO
  include IO

  getter crc : UInt64
  property size

  def initialize
    @crc = 0_u64
    @size = 0
  end

  def read(slice : Slice(UInt8))
    0
  end

  def write(slice : Slice(UInt8))
    @crc = Zlib.crc32(slice, @crc)
    @size += slice.size
  end

  def reset
    @crc = 0_u64
  end

end
