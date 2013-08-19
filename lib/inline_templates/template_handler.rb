module InlineTemplates
  class TemplateHandler
    def call(source)
      <<-EOF
        @output_buffer ||= ActionView::OutputBuffer.new
        context = ::InlineTemplates::RenderingContext.new(self, local_assigns, ::InlineTemplates::Builder.new)
        context.instance_exec do
          #{source.source}
        end
        @output_buffer.to_s
      EOF
    end
  end
end
