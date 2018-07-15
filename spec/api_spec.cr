require "minitest/autorun"
require "../src/stumpy_png"

module StumpyPNG
  class StumpyPNGAPITest < Minitest::Test
    def test_path_read_write
      canvas = StumpyPNG.read("./spec/png_suite/basic_formats/basn0g01.png")
      StumpyPNG.write(canvas, "/tmp/test.png")
    end

    def test_io_read_write
      in_io = IO::Memory.new
      File.open("./spec/png_suite/basic_formats/basn0g01.png", "rb") do |file|
        IO.copy(file, in_io)
      end
      in_io.rewind

      canvas = StumpyPNG.read(in_io)

      out_io = IO::Memory.new
      StumpyPNG.write(canvas, out_io)
    end
  end
end
