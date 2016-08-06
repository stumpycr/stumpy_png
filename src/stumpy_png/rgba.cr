require "./utils"

module StumpyPNG
  struct RGBA
    getter r : UInt16
    getter g : UInt16
    getter b : UInt16
    getter a : UInt16

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
      r, g, b, a = values
      from_rgba_n(r, g, b, a, n)
    end

    def self.from_rgba_n(r, g, b, a, n)
      red = Utils.scale_up(r, n)
      green = Utils.scale_up(g, n)
      blue = Utils.scale_up(b, n)
      alpha = Utils.scale_up(a, n)
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
      r, g, b = values
      from_rgb_n(r, g, b, n)
    end

    def self.from_rgb_n(r, g, b, n)
      red = Utils.scale_up(r, n)
      green = Utils.scale_up(g, n)
      blue = Utils.scale_up(b, n)
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
