module StumpyPNG
  module Utils
    def self.parse_integer(bytes)
      bytes.reduce(0) { |acc, byte| (acc << 8) + byte }
    end

    def self.bytes_to_uint32(bytes)
      bytes.reduce(0.to_u32) { |acc, byte| (acc << 8) + byte }
    end

    def self.uint32_to_bytes(int)
      [24, 16, 8, 0].map { |n| (int >> n & 0xff).to_u8 }
    end

    def self.read_n_byte(file, n)
      slice = Slice(UInt8).new(n)
      file.read_fully(slice)
      slice.to_a
    end

    def self.paeth_predictor(a8, b8, c8)
      a = a8.to_i16
      b = b8.to_i16
      c = c8.to_i16

      p = a + b - c # inital estimate

      pa = (p - a).abs # distances to a, b, c
      pb = (p - b).abs
      pc = (p - c).abs
      
      if pa <= pb && pa <= pc
        return a.to_u8
      elsif pb <= pc
        return b.to_u8
      else
        return c.to_u8
      end
    end

    def self.get_bit(byte, n)
      (byte & (1 << n)) >> n
    end

    def self.each_n_bit_integer(byte, n, &block)
      (8 / n).times do |integer|
        sum = 0
        (0...n).each do |bit|
          sum = sum * 2 + get_bit(byte, 7 - (integer * n + bit))
        end
        yield sum
      end
    end

    def self.scale_up(input, from)
      return input.to_u16 if from == 16
      (input.to_f / (2 ** from - 1) * (2 ** 16 - 1)).round.to_u16
    end

    def self.scale_from_to(input, from, to)
      (input.to_f / (2 ** from - 1) * (2 ** to - 1)).round
    end
  end
end
