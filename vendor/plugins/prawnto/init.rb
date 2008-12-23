require 'prawnto'

Mime::Type.register "application/pdf", :pdf
ActionView::Template.register_template_handler 'prawn', Prawnto::TemplateHandler::Base
ActionView::Template.register_template_handler 'prawnx', Prawnto::TemplateHandler::Raw  # experimental

