require "minitest/autorun"
require "../src/stumpy_png"

module StumpyPNG
  class PNGSuiteTest < Minitest::Test
    def test_png_write
      image = "./spec/png_suite/basic_formats/basn0g01.png"
      tmp_image = "/tmp/test.png"

      original = StumpyPNG.read(image)
      StumpyPNG.write(original, tmp_image)

      written = StumpyPNG.read(tmp_image)

      assert_equal original, written
    end
  end
end
