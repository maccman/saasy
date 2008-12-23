$LOAD_PATH << "#{File.dirname(__FILE__)}/lib"
require "ttfunk"

file = TTFunk::File.new("data/fonts/DejaVuSans.ttf")
p file.kern.sub_tables[0].keys.sort