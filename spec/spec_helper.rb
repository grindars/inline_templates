require 'action_controller'
require 'inline_templates'

def invoke_controller(controller, action)
  status, headers, content = controller.action(action).call({
    "rack.input" => StringIO.new,
    "REQUEST_METHOD" => "GET"
  })

  content.body
end

def test_rit(locals = {}, &template)
  inner_context = nil
  assigns = {}
  controller = nil
  formats = nil
   
  view = ActionView::Base.new inner_context, assigns, controller, formats

  def view.invoke_helper_like_class(klass, *args, &block)
    klass.new(self, *args, &block).to_s
  end

  InlineTemplates.render view, { virtual_path: "(inline)" }, locals, &template
end

class TestController < ActionController::Base
  ReferenceOutput = "<div>test</div>"

  include InlineTemplates::Helpers

  def test
    self.response_body = rit do
      ~ div("test")
    end
  end

  def test_file
    render :file => File.expand_path("../support/test.rit", __FILE__)
  end
end

