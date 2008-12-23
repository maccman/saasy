module PDF
  class Inspector
    class Page < Inspector
      attr_reader :pages   
      
      def initialize
        @pages = []
      end

      def begin_page(params)
        @pages << {:size => params[:MediaBox][-2..-1]}
      end                       
      
    end   
  end
end