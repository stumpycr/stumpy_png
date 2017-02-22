require "zlib"

require "crc32"

class CrcIO
  include IO

  getter crc : UInt32
  property size

  def initialize
    @crc = 0_u32
    @size = 0
  end

  def read(slice : Slice(UInt8))
    0
  end

  def write(slice : Slice(UInt8))
    @crc = CRC32.update(slice, @crc)
    @size += slice.size
  end

  def reset
    @crc = 0_u32
  end

end
