module TTFunk  
  class Table
    class Head < TTFunk::Table
      def initialize(fh, font, info)
        fh.pos = info[:offset]
        data = fh.read(20)
        @version, @font_revision, @check_sum_adjustment, @magic_number,
        @flags, @units_per_em = data.unpack("N4n2")
    
        # skip dates
        fh.read(16)
    
        data = fh.read(8)
        @x_min, @y_min, @x_max, @y_max = data.unpack("n4").map { |e| to_signed(e) }
    
        data = fh.read(4)
        @mac_style, @lowest_rec_ppem = data.unpack("n2")
    
        data = fh.read(6)
        @font_direction_hint, @index_to_loc_format, @glyph_data_format =
          data.unpack("n3")
      end
    end
  end
end