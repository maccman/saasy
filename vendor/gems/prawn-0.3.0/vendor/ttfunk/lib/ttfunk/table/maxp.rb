module TTFunk
  class Table
    class Maxp < Table
      def initialize(fh, font, info)
        fh.pos = info[:offset]
        @length = info[:length]
        data = fh.read(@length)
        @version, @num_glyphs, @max_points, @max_contours,
        @max_component_points,@max_component_contours, @max_zones,
        @max_twilight_points, @max_storage, @max_function_defs,
        @max_instruction_defs,@max_stack_elements,
        @max_size_of_instructions, @max_component_elements,
        @max_component_depth = data.unpack("Nn14")
      end
    end
  end
end