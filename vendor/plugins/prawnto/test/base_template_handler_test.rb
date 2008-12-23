require 'test/unit'
require File.dirname(__FILE__) + '/template_handler_test_mocks'
require File.dirname(__FILE__) + '/../lib/prawnto'
require File.dirname(__FILE__) + '/../init'


#TODO: ruby1.9: pull same testing scheme from Raw once we're on 1.9
class BaseTemplateHandlerTest < Test::Unit::TestCase
  include TemplateHandlerTestMocks
  
  def setup
    @view = ActionView.new
    @handler = Prawnto::TemplateHandler::Base.new(@view)
    @controller = @view.controller
  end

  def test_prawnto_options_dsl_hash
    @y = 3231; @x = 5322
    @controller.prawnto :dsl=> {'x'=>:@x, :y=>'@y'}
    @handler.pull_prawnto_options
    source = @handler.build_source_to_establish_locals(Template.new(""))

    assert_equal @x, eval(source + "\nx")
    assert_equal @y, eval(source + "\ny")
  end

  def test_prawnto_options_dsl_array
    @y = 3231; @x = 5322
    @controller.prawnto :dsl=> ['x', :@y]
    @handler.pull_prawnto_options
    source = @handler.build_source_to_establish_locals(Template.new(""))

    assert_equal @x, eval(source + "\nx")
    assert_equal @y, eval(source + "\ny")
  end

  def test_headers_disposition_inline_and_filename
    @controller.prawnto :filename=>'xxx.pdf', :inline=>true
    @handler.pull_prawnto_options
    @handler.set_disposition
    assert_equal 'inline;filename=xxx.pdf', @view.headers['Content-Disposition']
  end

  def test_headers_disposition_attachment_and_filename
    @controller.prawnto :filename=>'xxx.pdf', :inline=>false
    @handler.pull_prawnto_options
    @handler.set_disposition
    assert_equal 'attachment;filename=xxx.pdf', @view.headers['Content-Disposition']
  end

  def test_headers_disposition_default
    @handler.pull_prawnto_options
    @handler.set_disposition
    assert_equal 'inline', @view.headers['Content-Disposition']
  end

end

