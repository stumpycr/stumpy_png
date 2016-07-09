module StumpyPNG
  class Filter
    def self.apply(scanline, prior_scanline, bpp)
      decoded = [] of UInt8

      scanline.each_with_index do |byte, index|
        prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
        above = prior_scanline.empty? ? 0 : prior_scanline[index]
        upper_left = (prior_scanline.empty? || (index - bpp) < 0) ? 0 : prior_scanline[index - bpp]

        decoded << byte + function(prior, above, upper_left).to_u8
      end

      decoded
    end

    def self.function(prior, above, upper_left)
      0
    end
  end

  module Filters
    class None < Filter
      def self.apply(scanline, prior_scanline, bpp)
        scanline
      end
    end

    class Sub < Filter
      def self.function(prior, above, upper_left)
        prior
      end
    end

    class Up < Filter
      def self.function(prior, above, upper_left)
        above
      end
    end

    class Average < Filter
      def self.function(prior, above, upper_left)
        ((prior.to_f + above.to_f) / 2).floor.to_u8
      end
    end

    class Paeth < Filter
      def self.function(prior, above, upper_left)
        Utils.paeth_predictor(prior, above, upper_left)
      end
    end
  end
end
