require "./utils"

# include StumpyPNG::Utils

module StumpyPNG
  class RGBA
    property r : UInt16
    property g : UInt16
    property b : UInt16
    property a : UInt16

    def initialize(@r, @g, @b, @a)
    end

    def add(other)
      new_a = @a + other.a

      RGBA.new(
        (@r.to_f / new_a * @a + other.r.to_f / new_a * other.a).to_u16,
        (@g.to_f / new_a * @a + other.g.to_f / new_a * other.a).to_u16,
        (@b.to_f / new_a * @a + other.b.to_f / new_a * other.a).to_u16,
        new_a,
      )
    end

    def self.from_rgba_n(values, n)
      red   = Utils.scale_up(values[0], n)
      green = Utils.scale_up(values[1], n)
      blue  = Utils.scale_up(values[2], n)
      alpha = Utils.scale_up(values[3], n)
      RGBA.new(red, green, blue, alpha)
    end

    def self.from_gray_n(value, n)
      gray  = Utils.scale_up(value, n)
      RGBA.new(gray, gray, gray, UInt16::MAX)
    end

    def self.from_graya_n(values, n)
      gray  = Utils.scale_up(values[0], n)
      alpha = Utils.scale_up(values[1], n)
      RGBA.new(gray, gray, gray, alpha)
    end

    def self.from_rgb_n(values, n)
      red   = Utils.scale_up(values[0], n)
      green = Utils.scale_up(values[1], n)
      blue  = Utils.scale_up(values[2], n)
      RGBA.new(red, green, blue, UInt16::MAX)
    end

    def to_rgb8
      {
        Utils.scale_from_to(r, 16, 8).to_u8,
        Utils.scale_from_to(g, 16, 8).to_u8,
        Utils.scale_from_to(b, 16, 8).to_u8,
      }
    end

    def to_rgba8
      {
        Utils.scale_from_to(r, 16, 8).to_u8,
        Utils.scale_from_to(g, 16, 8).to_u8,
        Utils.scale_from_to(b, 16, 8).to_u8,
        Utils.scale_from_to(a, 16, 8).to_u8,
      }
    end
  end
end
