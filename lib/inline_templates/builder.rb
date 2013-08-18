module InlineTemplates
  class Builder
    def build(context, name, *args, &block)
      context.content_tag name, *args, &block
    end
 
    def can_build?(name)
      true
    end
  end
end
