require "active_support"
require "action_view"

require "inline_templates/version"
require "inline_templates/builder"
require "inline_templates/buffer_wrapper"
require "inline_templates/rendering_context"
require "inline_templates/helper"

module InlineTemplates
  def self.render(view, details, locals, &block)
    identifier = "(inline:#{block.inspect})"
 
    handler = ->(template) do
      method_name = nil
      template.instance_exec do
        method_name = self.method_name
 
        view.singleton_class.send :define_method, "#{method_name}_block" do
          block 
        end
      end
 
      <<-EOF
        @output_buffer ||= ActionView::OutputBuffer.new
        context = ::InlineTemplates::RenderingContext.new(self, local_assigns, ::InlineTemplates::Builder.new)
        context.instance_exec &self.#{method_name}_block
        @output_buffer.to_s
      EOF
    end
 
    template = ActionView::Template.new("", identifier, handler, details)
    template.send :compile!, view
    template.render view, locals
  end
end
