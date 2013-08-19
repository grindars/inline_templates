module InlineTemplates
  class BufferWrapper < BasicObject
    def initialize(object, buffer)
      @object = object
      @buffer = buffer
    end

    def __inline_templates_object; @object; end
 
    [ :!, :!=, :==, :__id__, :__send__, :equal?, :instance_eval, :instance_exec ].each do |method|
      define_method method do |*args, &block|
        args.map! &BufferWrapper.method(:unwrap)

        @object.__send__ method, *args, &block
      end
    end
 
    def ~
      @buffer.append = @object
      @object
    end
 
    def method_missing(name, *args, &block)
      if name == :respond_to? && args.length >= 1 && args.first == :__inline_templates_object
        return true
      end

      args.map! &BufferWrapper.method(:unwrap)

      BufferWrapper.wrap @object.__send__(name, *args, &block), @buffer
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
