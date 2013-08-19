module InlineTemplates
  class BufferWrapper < BlankObject
    make_blank :respond_to?

    def initialize(object, buffer)
      @object = object
      @buffer = buffer
    end

    def __inline_templates_object; @object; end
 
    def ~
      @buffer.instance_variable_get(:@_inlinetemplates_context).output_buffer.append = @object
      @object
    end

    def method_missing(name, *args, &block)
      args.map! &BufferWrapper.method(:unwrap)
      block = BufferWrapper.create_proxy_proc(block, @buffer) unless block.nil?

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

    def self.create_proxy_proc(nested, buffer)
      proc do |*args, &block|
        unless @_inlinetemplates_context.nil?
          ::Kernel.puts "OH! block in context!"
        end

        args.map! { |arg| BufferWrapper.wrap arg, buffer }
        block = BufferWrapper.create_proxy_proc(block, buffer) unless block.nil?

        nested.call *args, &block
      end
    end
  end
end
