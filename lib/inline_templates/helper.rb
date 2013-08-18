module InlineTemplates
  module Helpers
    extend ActiveSupport::Concern
    
    def rit(locals = {}, &block)
      InlineTemplates.render(view_context, {}, locals, &block)
    end

    included do
      protected :rit
    end
  end
end
