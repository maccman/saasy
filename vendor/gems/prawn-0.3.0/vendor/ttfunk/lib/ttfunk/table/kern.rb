module TTFunk
  class Table
    class Kern < Table
      def initialize(fh, font, info)
        fh.pos = info[:offset]
        data = fh.read(4)
        @fh = fh
        @version, @table_count = data.unpack("n2")
        
        @table_headers = {}
        
        @table_count.times do
          version, length, coverage = fh.read(6).unpack("n3")
          @table_headers[version] = { :length   => length, 
                                      :coverage => coverage,
                                      :format   => coverage >> 8 }
        end   
        
        generate_subtables
      end
        
      def generate_subtables
        @sub_tables = {}
        @table_headers.each do |version, data|
          if data[:format].zero?
            @sub_tables[0] = parse_subtable_format0
          else
            warn "TTFunk does not support kerning tables of format #{data[:format]}"
          end
        end
      end
      
      def parse_subtable_format0
        sub_table = {}
        pair_count, search_range, entry_selector, range_shift = @fh.read(8).unpack("n4")
        
        pair_count.times do
          left, right = @fh.read(4).unpack("n2")
          fword = to_signed(@fh.read(2).unpack("n").first)
          sub_table[[left,right]] = fword
        end
        
        return sub_table
      end
      
    end
  end
end