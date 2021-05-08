require "digest/crc32"

class CrcIO < IO
  getter crc = 0_u32
  property size = 0_i32

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
