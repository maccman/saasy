require 'action_controller'
require 'action_view'

require 'prawn'
require 'prawnto/action_controller'

require 'prawnto/template_handler/base'
require 'prawnto/template_handler/raw'

# for now applying to all Controllers
# however, could reduce footprint by letting user mixin (i.e. include) only into controllers that need it
# but does it really matter performance wise to include in a controller that doesn't need it?  doubtful-- depends how much of a hit the before_filter is i guess.. 
#

class ActionController::Base
  include Prawnto::ActionController
end



