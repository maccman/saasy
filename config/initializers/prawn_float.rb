module Prawn
  class Document
    def float(point, options = {}, &block)
      Float.new(point, options.merge(:for => self), &block).render
    end
    
    class Float #:nodoc:
      def initialize(point, options={}, &block)
        @document  = options[:for]
        @point     = point
        @width     = options[:width] || @document.bounds.width
        @block     = block
      end
  
      def render
        y = @document.y
        box = @document.bounding_box(@point, 
          :width => @width) do
          @block.call
        end
        @document.y = y
      end
    end
  end
end