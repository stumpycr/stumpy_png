require "minitest/autorun"

require "../src/png"

module StumpyPNG
  class PNGSuiteTest < Minitest::Test
    def test_basic_suite
      images = %w(
        basn0g01.png
        basn0g02.png
        basn0g04.png
        basn0g08.png
        basn0g16.png

        basn2c08.png
        basn2c16.png

        basn3p01.png
        basn3p02.png
        basn3p04.png
        basn3p08.png

        basn4a08.png
        basn4a16.png

        basn6a08.png
        basn6a16.png
      ).map { |f| File.join("./test/png_suite", f)}

      # images = Dir["./test/png_suite/*.png"]
      images.each do |image|
        png = PNG.read(image)
        canvas = png.to_canvas

        reference_path = image.gsub(".png", ".rgba")
        # FIXME: For some reason -gamma 1 does not work as expected
        system "convert -depth 8 -compress none -gamma 0.999999 #{image} #{reference_path}"

        reference = File.read(reference_path).bytes
        rgba = canvas.pixels.map(&.to_rgba8).map(&.to_a).flatten

        assert_equal reference, rgba
      end
    end
  end
end
