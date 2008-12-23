module ActionView
  module Helpers
    module FormTagHelper
      # Add ':' automatically
      def label_tag(name, text = nil, options = {})
        content_tag :label, (text || name.to_s.humanize) + (text.blank? ? '' : ':'), { "for" => name }.update(options.stringify_keys)
      end
    end
  end
end