require "minitest/autorun"

require "../src/stumpy_png"

module StumpyPNG
  class PNGSuiteTest < Minitest::Test
    def image_test_helper(path)
      images = Dir[path]
      images.each do |image|
        png = PNG.read(image)
        canvas = png.to_canvas

        reference_path = image.gsub(".png", ".rgba")
        # FIXME: For some reason -gamma 1 does not work as expected
        # system "convert -depth 8 -compress none -gamma 0.999999 #{image} #{reference_path}"

        reference = File.read(reference_path).bytes
        rgba = canvas.pixels.map(&.to_rgba8).map(&.to_a).flatten

        assert_equal reference, rgba
      end
    end

    def test_basic_formats
      image_test_helper("./test/png_suite/basic_formats/*.png")
    end

    def test_image_filtering
      image_test_helper("./test/png_suite/image_filtering/*.png")
    end

    def test_chunk_ordering
      image_test_helper("./test/png_suite/chunk_ordering/*.png")
    end

    def test_interlacing
      image_test_helper("./test/png_suite/interlacing/*.png")
    end

    def test_odd_sizes
      image_test_helper("./test/png_suite/odd_sizes/*.png")
    end

    def test_zlib_compression
      image_test_helper("./test/png_suite/zlib_compression/*.png")
    end
  end
end
