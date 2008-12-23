module TTFunk  
  class Table
    class Cmap < Table
      def initialize(fh, font, info)
        @file = fh
        @file.pos = info[:offset]
    
        @version, @table_count = @file.read(4).unpack("n2")
    
        process_subtables(info[:offset])
      end
    
      private
    
      def process_subtables(table_start)
        @sub_tables = {}
        @formats = {}
        @table_count.times do
          platform_id, encoding_id, offset = @file.read(8).unpack("n2N")
          @sub_tables[[platform_id, encoding_id]] = offset
        end
    
        @sub_tables.each do |ident, offset|
          @file.pos = table_start + offset
          format = @file.read(2).unpack("n").first 
          case format
          when 0
            read_format0
          when 4
            read_format4(table_start)
          else
            if $DEBUG
              warn "TTFunk: Format #{format} not implemented, skipping"
            end
          end
        end 
      end
    
      def read_segment
        @file.read(@segcount_x2).unpack("n#{@segcount_x2 / 2}")
      end
    
      def read_format0
        @file.read(4) # skip length, language for now
        glyph_ids = @file.read(256).unpack("C256")
        @formats[0] = glyph_ids
      end
    
      def read_format4(table_start)
        @formats[4] = {}
    
        length, language = @file.read(4).unpack("n2")
        @segcount_x2, search_range, entry_selector, range_shift = 
          @file.read(8).unpack("n4")
    
        extract_format4_glyph_ids(table_start)
      end
   
      def extract_format4_glyph_ids(table_start)
        end_count = read_segment
     
        @file.read(2) # skip reserved value
     
        start_count = read_segment
        id_delta = read_segment.map { |e| to_signed(e) }
        id_range_offset = read_segment
     
        remaining_shorts = (@file.pos - table_start) / 2
        glyph_ids = @file.read(remaining_shorts*2).unpack("n#{remaining_shorts}")
       
        start_count.each_with_index do |start, i|
          end_i = end_count[i]
          delta = id_delta[i]
          range = id_range_offset[i]
        
          start.upto(end_i) do |char|
            if range.zero?
               gid = char + delta
            else
              gindex = range / 2 + (char - start_count[i]) - 
                  (segcount_x2 / 2 - i)
              gid = glyph_ids[gindex] || 0
              gid += id_delta[i] if gid != 0   
            end   
            gid %= 65536 
         
            @formats[4][char] = gid
          end
        end
      end    
    end
    
  end
end