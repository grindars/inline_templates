module InlineTemplates
  class BufferWrapper < BlankObject
    make_blank :respond_to?

    def initialize(object, buffer)
      @object = object
      @buffer = buffer
    end

    def __inline_templates_object; @object; end
 
    def ~
      @buffer.append = @object
      @object
    end

    def method_missing(name, *args, &block)
      args.map! &BufferWrapper.method(:unwrap)

      BufferWrapper.wrap @object.__send__(name, *args, &block), @buffer
    end

    def respond_to_missing?(name, include_private = false)
      @object.respond_to?(name, include_private)
    end
 
    def self.wrap(result, buffer)
      if result.class == ::NilClass || result.class == ::TrueClass || result.class == ::FalseClass
        result
      else
        BufferWrapper.new(self.unwrap(result), buffer)
      end
    end

    def self.unwrap(obj)
      if obj.respond_to? :__inline_templates_object
        obj.__inline_templates_object
      else
        obj
      end
    end
  end
end
