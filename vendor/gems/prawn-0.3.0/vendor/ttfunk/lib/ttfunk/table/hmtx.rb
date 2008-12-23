module TTFunk  
  class Table 
    class Hmtx < Table
      def initialize(fh, font, info)
        fh.pos = info[:offset]
        @values = []

        font.hhea.number_of_hmetrics.times do
          advance = fh.read(2).unpack("n").first
          lsb     = to_signed(fh.read(2).unpack("n").first)
          @values << [advance,lsb]
        end
    
        lsb_count = font.hhea.number_of_hmetrics - font.maxp.num_glyphs
        pattern = "n#{lsb_count}"
        @lsb = fh.read(2*lsb_count).unpack(pattern).map { |e| to_signed(e) }
      end
    end
  end
end