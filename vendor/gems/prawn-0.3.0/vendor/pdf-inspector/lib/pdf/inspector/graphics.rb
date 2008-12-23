module PDF
  class Inspector 
    module Graphics                   
      class Line < Inspector
        attr_accessor :points, :widths

        def initialize
          @points = []
          @widths = [] 
        end  

        def append_line(*params)
          @points << params
        end    

        def begin_new_subpath(*params)
          @points << params
        end           
        
        def set_line_width(params)
          @widths << params
        end

      end 
      
      class Rectangle < Inspector
        attr_reader :rectangles

        def initialize
          @rectangles = []     
        end

        def append_rectangle(*params) 
          @rectangles << { :point  => params[0..1],    
                           :width  => params[2],
                           :height => params[3]  }     
        end
      end
      
      class Curve < Inspector

        attr_reader :coords

        def initialize
          @coords = []          
        end   

        def begin_new_subpath(*params)   
          @coords += params
        end

        def append_curved_segment(*params)
          @coords += params
        end           

      end   
      
      class Color < Inspector
        attr_reader :stroke_color, :fill_color, :stroke_color_count, 
                    :fill_color_count

        def initialize
          @stroke_color_count = 0
          @fill_color_count   = 0
        end

        def set_rgb_color_for_stroking(*params)    
          @stroke_color_count += 1
          @stroke_color = params
        end

        def set_rgb_color_for_nonstroking(*params) 
          @fill_color_count += 1
          @fill_color = params
        end
      end 
      
    end                                
  end
end