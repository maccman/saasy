module TTFunk
  class Table
    class Name < Table
      def initialize(fh, font, info)
        fh.pos = info[:offset]
        data = fh.read(6)
        @table_start = info[:offset]
        @format, @record_count, @string_offset = data.unpack("nnn")
        parse_name_records(fh)
        parse_strings(fh)
      end
  
      def parse_name_records(fh)
        @records = {}
        @record_count.times { @records.update(parse_name_record(fh)) }
      end
  
      def parse_name_record(fh)
        data = fh.read(12).unpack("n6")
        platform, encoding, language, id, length, offset = data
        { id => { 
            :platform => platform, :encoding => encoding, 
            :language => language, :length   => length,
            :offset   => offset } }
      end
  
      def parse_strings(fh)
        @strings = @records.inject({}) do |s,v|
          id, options = v
      
          fh.pos = @table_start + @string_offset + options[:offset]
          s.merge(id => fh.read(options[:length]).delete("\000"))
        end
      end
  
      def name_data 
        [:copyright, :font_family, :font_subfamily, :unique_subfamily_id,
         :full_name, :name_table_version, :postscript_name, :trademark_notice,
         :manufacturer_name, :designer, :description, :vendor_url,
         :designer_url, :license_description, :license_info_url ]
      end
    
      def method_missing(*args,&block)
        if name_data.include?(args.first)
          @strings[name_data.index(args.first)]
        else
          super
        end
      end
    end
  end
end