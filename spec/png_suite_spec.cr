require "minitest/autorun"
require "../src/stumpy_png"

module StumpyPNG
  class StumpyPNGSuiteTest < Minitest::Test
    def image_test_helper(path)
      images = Dir[path]
      images.each do |image|
        canvas = StumpyPNG.read(image)

        reference_path = image.gsub(".png", ".rgba")
        # FIXME: For some reason -gamma 1 does not work as expected
        # system "convert -depth 8 -compress none -gamma 0.999999 #{image} #{reference_path}"

        reference = File.read(reference_path).bytes
        rgba = canvas.pixels.map(&.to_rgba).to_a.map(&.to_a).flatten

        assert_equal reference, rgba
      end
    end

    def test_basic_formats
      image_test_helper("./spec/png_suite/basic_formats/*.png")
    end

    def test_image_filtering
      image_test_helper("./spec/png_suite/image_filtering/*.png")
    end

    def test_chunk_ordering
      image_test_helper("./spec/png_suite/chunk_ordering/*.png")
    end

    def test_interlacing
      image_test_helper("./spec/png_suite/interlacing/*.png")
    end

    def test_odd_sizes
      image_test_helper("./spec/png_suite/odd_sizes/*.png")
    end

    def test_zlib_compression
      image_test_helper("./spec/png_suite/zlib_compression/*.png")
    end

    def test_corrupted_files__invalid_signature
      images = %w(
        ./spec/png_suite/corrupted_files/xs1n0g01.png
        ./spec/png_suite/corrupted_files/xs2n0g01.png
        ./spec/png_suite/corrupted_files/xs4n0g01.png
        ./spec/png_suite/corrupted_files/xs7n0g01.png
        ./spec/png_suite/corrupted_files/xcrn0g04.png
        ./spec/png_suite/corrupted_files/xlfn0g04.png
      )

      images.each do |image|
        err = assert_raises Exception do
          StumpyPNG.read(image)
        end
        assert_equal err.message, "Not a png file"
      end
    end

    def test_corrupted_files__invalid_color_type
      images = %w(
        ./spec/png_suite/corrupted_files/xc1n0g08.png
        ./spec/png_suite/corrupted_files/xc9n2c08.png
      )

      images.each do |image|
        err = assert_raises Exception do
          StumpyPNG.read(image)
        end
        assert_equal err.message, "Invalid color type"
      end
    end

    def test_corrupted_files__invalid_color_type
      images = %w(
        ./spec/png_suite/corrupted_files/xd0n2c08.png
        ./spec/png_suite/corrupted_files/xd3n2c08.png
        ./spec/png_suite/corrupted_files/xd9n2c08.png
      )

      images.each do |image|
        err = assert_raises Exception do
          StumpyPNG.read(image)
        end
        assert_equal err.message, "Invalid bit depth for this color type"
      end
    end

    def test_corrupted_files__missing_IDAT_chunk
      image = "./spec/png_suite/corrupted_files/xdtn0g01.png"
      err = assert_raises Exception do
        StumpyPNG.read(image)
      end
      assert_equal err.message, "Missing IDAT chunk"
    end

    def test_corrupted_files__incorrect_IDAT_checksum
      image = "./spec/png_suite/corrupted_files/xcsn0g01.png"
      err = assert_raises Exception do
        StumpyPNG.read(image)
      end
      assert_equal err.message, "Incorrect checksum"
    end
  end
end
