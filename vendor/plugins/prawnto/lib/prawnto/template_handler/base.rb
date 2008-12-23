module Prawnto
  module TemplateHandler
    class Base < ActionView::TemplateHandler

      attr_reader :prawnto_options
      
      def initialize(view)
        @view = view
      end

      def self.call(template)
        "Prawnto::TemplateHandler::Base.new(self).render(template, local_assigns)"
      end

      # TODO: kept around from railspdf-- maybe not needed anymore? should check.
      def ie_request?
        @view.request.env['HTTP_USER_AGENT'] =~ /msie/i
      end

      # TODO: kept around from railspdf-- maybe not needed anymore? should check.
      def set_pragma
        @view.headers['Pragma'] ||= ie_request? ? 'no-cache' : ''
      end

      # TODO: kept around from railspdf-- maybe not needed anymore? should check.
      def set_cache_control
        @view.headers['Cache-Control'] ||= ie_request? ? 'no-cache, must-revalidate' : ''
      end

      def set_content_type
        @view.response.content_type = Mime::PDF
      end

      def set_disposition
        inline = @prawnto_options[:inline] ? 'inline' : 'attachment'
        filename = @prawnto_options[:filename] ? "filename=#{@prawnto_options[:filename]}" : nil
        @view.headers["Content-Disposition"] = [inline,filename].compact.join(';')
      end

      def build_headers
        set_pragma
        set_cache_control
        set_content_type
        set_disposition
      end

      def build_source_to_establish_locals(template, local_assigns = {})
        prawnto_locals = {}
        if dsl = @prawnto_options[:dsl]
          if dsl.kind_of?(Array)
            dsl.each {|v| v = v.to_s.gsub(/^@/,''); prawnto_locals[v]="@#{v}"}
          elsif dsl.kind_of?(Hash)
            prawnto_locals.merge!(dsl)
          end
        end
        prawnto_locals.merge!(local_assigns)
        prawnto_locals.map {|k,v| "#{k} = #{v};"}.join("")
      end

      def pull_prawnto_options
        @prawnto_options = @view.controller.send :compute_prawnto_options
      end

      def render(template, local_assigns = {})
        pull_prawnto_options
        build_headers

        source = build_source_to_establish_locals(template, local_assigns = {})
        if @prawnto_options[:dsl]
          source += "pdf.instance_eval do\n#{template.source}\nend"
        else
          source += "\n#{template.source}"
        end

        pdf = Prawn::Document.new(@prawnto_options[:prawn])
        @view.instance_eval source, template.filename, 1
        pdf.render
      end

    end
  end
end
