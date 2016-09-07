module StumpyPNG
  module Filter
    def self.apply(scanline : Slice(UInt8), prior_scanline : Slice(UInt8), bpp, filter)
      # Filter = NONE
      return scanline if filter == 0

      decoded = Slice(UInt8).new(scanline.size)

      scanline.each_with_index do |byte, index|
        prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
        above = prior_scanline.empty? ? 0 : prior_scanline[index]
        upper_left = (prior_scanline.empty? || (index - bpp) < 0) ? 0 : prior_scanline[index - bpp]

        case filter
        when 1 # Sub
          decoded[index] = byte + prior
        when 2 # Up
          decoded[index] = byte + above
        when 3 # Average
          decoded[index] = byte + ((prior.to_f + above.to_f) / 2).floor.to_u8
        when 4 # Paeth
          decoded[index] = byte + Utils.paeth_predictor(prior, above, upper_left)
        else
          raise "Unknown filter type #{filter}"
        end
      end

      decoded
    end
  end
end
