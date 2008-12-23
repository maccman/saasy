module TTFunk
  class Table
    class Directory < Table
      def initialize(fh)
        @scaler_type, @table_count, @search_range,
        @entry_selector, @range_shift = fh.read(12).unpack("Nnnnn")
        parse_table_list(fh)
      end
  
      def parse_table_list(fh)
        first_table = parse_table(fh)
        @tables = first_table
        offset = first_table[first_table.keys.first][:offset]

        @tables.update(parse_table(fh)) while fh.pos < offset
      end
  
      def parse_table(fh)
        tag, checksum, offset, length = fh.read(16).unpack("a4NNN")
        { tag => { 
            :checksum => checksum, :offset => offset, :length => length } }
      end    
    end
  end
end