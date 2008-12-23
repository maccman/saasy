module RestResponses
  
  class BaseError < Exception
  end
  
  class ParamsInvalid < BaseError
    @@http_status = 406
    cattr_accessor :http_status
  end
  
  extend self
   module ControllerMethods
     
     # Some example rescues in application.rb:
     # 
     # rescue_from ActiveRecord::RecordInvalid do |exception|
     #   responds_error_with_info(exception.record.errors)
     # end
     # 
     # rescue_from ActiveRecord::RecordNotFound do |exception|
     #   responds_error(404)
     # end
     # 
     # rescue_from RestResponses::BaseError do |exception|
     #   responds_error(exception.http_status)
     # end
     # 
     # rescue_from ActiveRecord::StaleObjectError do |exception|
     #   responds_error(409)
     # end
     
     # Returns data to clients in the format they've requested, add and remove responses
     # as appropriate. We have to turn the object into xml first, before creating json/yaml
     # as they otherwise don't have the right structure.
     # For example:
     # def update
     #  @asset = Asset.update_attributes!(params[:asset])
     #  responds(@asset)
     # end
     def responds(ob, options = {})
       status = (options.delete(:status) || 200)
       respond_to do |wants|
         wants.html { }
         wants.xml  { render :xml => ob.to_xml(options), :status => status }
         wants.json { render :json => (Hash.from_xml(ob.to_xml(options))).to_json, :status => status }
         wants.yaml { render :yaml => (Hash.from_xml(ob.to_xml(options))).to_yaml, :status => status }
       end
     end
     
     # This is used for requiring certain parameters in controllers, so when you come
     # to use them you can assume they're there.
     # For example:
     # def email
     #  needs :name, :email, :msg
     #  # ...
     # end
     def needs(*args)
       args.each do |arg|
         raise RestResponses::ParamsInvalid unless params[arg]
       end
     end

     # Renders the created record, and also forwards to the new record.
     def responds_creation(ob, options = {})
       headers["Location"] = url_for(ob)
       options[:status] ||= 201
       responds(ob, options)
     end

     def responds_deletion
       render :nothing => true, :status => 204
     end

     def responds_error(status = 405)
       render :text => "There has been an error: #{status}", :status => status
     end

     def responds_updation(ob, options = {})
       options[:status] ||= 200
       responds(ob, options)
     end

     def responds_error_with_info(ob, options = {})
       options[:status] ||= 422
       responds(ob, options)
     end

     def responds_nothing(status = 200)
       render :nothing => true, :status => status
     end
     
     # Rails/Ruby still regards params with a value of 'false' as true
     # def params
     #   super.each {|p,value| super[p] = false if value == "false" }
     # end
     
   end
end