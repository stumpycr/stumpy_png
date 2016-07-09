require "minitest/autorun"

require "../src/datastream"

module StumpyPNG
  class PNGSuiteTest < Minitest::Test
    def test_raw
      # random test image
      image = "./test/png_suite/basic_formats/basn0g01.png"
      reference = File.read(image).bytes
      raw = Datastream.read(image).raw

      assert_equal raw, reference
    end
  end
end
