module TTFunk  
  class Table
    class Hhea < Table
      def initialize(fh, font, info)
        fh.pos = info[:offset]
        @length = info[:length]
        data   = fh.read(4)
        @version = data.unpack("N")
    
        data = fh.read(6)
        @ascent, @descent, @line_gap= data.unpack("n3").map {|e| to_signed(e) } 
    
        data = fh.read(2) 
        @advance_width_max = data.unpack("n")
    
        data = fh.read(22)
        @min_left_side_bearing, @min_right_side_bearing, @x_max_extent, 
        @caret_slope_rise, @caret_slope_run,
        @caret_offset, _, _, _, _, @metric_data_format =
        data.unpack("n11").map {|e| to_signed(e) }
    
        data = fh.read(2)
        @number_of_hmetrics = data.unpack("n").first
      end
    end
  end
end