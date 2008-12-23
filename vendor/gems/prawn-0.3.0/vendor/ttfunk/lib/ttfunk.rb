module TTFunk
  class File
    def initialize(file)
       @file = file
       open_file { |fh| @directory = Table::Directory.new(fh) }
    end
    
    def open_file
      ::File.open(@file,"rb") do |fh|
        yield(fh)
      end
    end
    
    def self.has_tables(*tables)
      tables.each { |t| has_table(t) }
    end
    
    def self.has_table(t)
      t = t.to_s
      
      define_method t do
        var = "@#{t}"
        if ivar = instance_variable_get(var) 
          return ivar  
        else
          klass = Table.const_get(t.capitalize)
          open_file do |fh| 
            instance_variable_set(var, 
              klass.new(fh, self, directory_info(t)))
          end
        end
      end
    end
    
    def directory_info(table)
      directory.tables[table.to_s]
    end
    
    def method_missing(id,*a,&b)
      super unless id.to_s["?"]
      !!directory_info(id.to_s.chop)
    end
    
    attr_reader :directory
  end   
end

require "ttfunk/table"