module StumpyPNG
  module Utils
    def self.parse_integer(bytes)
      bytes.reduce(0) { |acc, byte| (acc << 8) + byte }
    end

    def self.bytes_to_uint32(bytes)
      bytes.reduce(0.to_u32) { |acc, byte| (acc << 8) + byte }
    end

    def self.uint32_to_bytes(int)
      {24, 16, 8, 0}.map { |n| (int >> n & 0xff).to_u8 }
    end

    def self.uint16_to_bytes(int)
      {8, 0}.map { |n| (int >> n & 0xff).to_u8 }
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
        a.to_u8
      elsif pb <= pc
        b.to_u8
      else
        c.to_u8
      end
    end

    class NBitEnumerable
      include Enumerable(UInt16)

      property values : Slice(UInt8)
      property size

      def initialize(@values, @size = 8_u8)
      end

      def each(&block)
        case @size
        when 1
          values.each do |byte|
            (0...8).reverse_each do |n|
              yield ((byte & (0b1 << n)) >> n).to_u16
            end
          end
        when 2
          values.each do |byte|
            (0...4).reverse_each do |n|
              yield ((byte & (0b11 << (n * 2))) >> (n * 2)).to_u16
            end
          end
        when 4
          values.each do |byte|
            (0...2).reverse_each do |n|
              yield ((byte & (0b1111 << (n * 4))) >> (n * 4)).to_u16
            end
          end
        when 8
          values.each do |byte|
            yield byte.to_u16
          end
        when 16
          values.each_slice(2) do |bytes|
            yield Utils.parse_integer(bytes).to_u16
          end
        end
      end
    end
  end
end
