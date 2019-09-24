module StumpyPNG
  module Filter
    def self.apply(scanline : Bytes, prior_scanline : Bytes, decoded : Bytes, bpp, filter) : Bytes
      case filter
      when 0 # None
        return scanline
      when 1 # Sub
        scanline.each_with_index do |byte, index|
          prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
          decoded[index] = byte &+ prior
        end
      when 2 # Up
        scanline.each_with_index do |byte, index|
          above = prior_scanline[index]
          decoded[index] = byte &+ above
        end
      when 3 # Average
        scanline.each_with_index do |byte, index|
          prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
          above = prior_scanline[index]
          decoded[index] = byte &+ ((prior.to_f + above.to_f) / 2).floor.to_u8
        end
      when 4 # Paeth
        scanline.each_with_index do |byte, index|
          prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
          above = prior_scanline[index]
          upper_left = (index - bpp) < 0 ? 0 : prior_scanline[index - bpp]
          decoded[index] = byte &+ Utils.paeth_predictor(prior, above, upper_left)
        end
      else
        raise "Unknown filter type #{filter}"
      end

      decoded
    end

    def self.apply(scanline : Bytes, prior_scanline : Nil, decoded : Bytes, bpp, filter) : Bytes
      case filter
      when 0 # None
        return scanline
      when 1 # Sub
        scanline.each_with_index do |byte, index|
          prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
          decoded[index] = byte &+ prior
        end
      when 2 # Up
        scanline.each_with_index do |byte, index|
          decoded[index] = byte
        end
      when 3 # Average
        scanline.each_with_index do |byte, index|
          prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
          decoded[index] = byte &+ (prior.to_f / 2).floor.to_u8
        end
      when 4 # Paeth
        scanline.each_with_index do |byte, index|
          prior = (index - bpp) < 0 ? 0 : decoded[index - bpp]
          decoded[index] = byte &+ Utils.paeth_predictor(prior, 0, 0)
        end
      else
        raise "Unknown filter type #{filter}"
      end

      decoded
    end
  end
end
