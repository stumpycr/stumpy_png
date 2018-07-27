require "minitest/autorun"
require "../src/stumpy_png"

module StumpyPNG
  class PNGSuiteTest < Minitest::Test
    def test_png_write_16bit_grayscale
      image = "./spec/png_suite/basic_formats/basn0g16.png"
      tmp_image = "/tmp/test_8_gray.png"

      original = StumpyPNG.read(image)
      StumpyPNG.write(original, tmp_image, bit_depth: 16, color_type: :grayscale)

      written = StumpyPNG.read(tmp_image)
      assert_equal original, written
    end

    def test_png_write_16bit_grayscale_alpha
      image = "./spec/png_suite/basic_formats/basn0g16.png"
      tmp_image = "/tmp/test_8_graya.png"

      original = StumpyPNG.read(image)
      StumpyPNG.write(original, tmp_image, bit_depth: 16, color_type: :grayscale_alpha)

      written = StumpyPNG.read(tmp_image)
      assert_equal original, written
    end

    def test_png_write_16bit_rgb
      image = "./spec/png_suite/basic_formats/basn2c16.png"
      tmp_image = "/tmp/test_8_rgb.png"

      original = StumpyPNG.read(image)
      StumpyPNG.write(original, tmp_image, bit_depth: 16, color_type: :rgb)

      written = StumpyPNG.read(tmp_image)
      assert_equal original, written
    end

    def test_png_write_16bit_rgb_alpha
      image = "./spec/png_suite/basic_formats/basn4a16.png"
      tmp_image = "/tmp/test_8_rgba.png"

      original = StumpyPNG.read(image)
      StumpyPNG.write(original, tmp_image, bit_depth: 16, color_type: :rgb_alpha)

      written = StumpyPNG.read(tmp_image)
      assert_equal original, written
    end

    def test_png_write_8bit_grayscale
      image = "./spec/png_suite/basic_formats/basn0g08.png"
      tmp_image = "/tmp/test_8_gray.png"

      original = StumpyPNG.read(image)
      StumpyPNG.write(original, tmp_image, bit_depth: 8, color_type: :grayscale)

      written = StumpyPNG.read(tmp_image)
      assert_equal original, written
    end

    def test_png_write_8bit_grayscale_alpha
      image = "./spec/png_suite/basic_formats/basn0g08.png"
      tmp_image = "/tmp/test_8_graya.png"

      original = StumpyPNG.read(image)
      StumpyPNG.write(original, tmp_image, bit_depth: 8, color_type: :grayscale_alpha)

      written = StumpyPNG.read(tmp_image)
      assert_equal original, written
    end

    def test_png_write_8bit_rgb
      image = "./spec/png_suite/basic_formats/basn2c08.png"
      tmp_image = "/tmp/test_8_rgb.png"

      original = StumpyPNG.read(image)
      StumpyPNG.write(original, tmp_image, bit_depth: 8, color_type: :rgb)

      written = StumpyPNG.read(tmp_image)
      assert_equal original, written
    end

    def test_png_write_8bit_rgb_alpha
      image = "./spec/png_suite/basic_formats/basn4a08.png"
      tmp_image = "/tmp/test_8_rgba.png"

      original = StumpyPNG.read(image)
      StumpyPNG.write(original, tmp_image, bit_depth: 8, color_type: :rgb_alpha)

      written = StumpyPNG.read(tmp_image)
      assert_equal original, written
    end
  end
end
