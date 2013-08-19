module InlineTemplates
  class BufferWrapper < BlankObject
    make_blank :respond_to?

    def initialize(object, buffer)
      @object = object
      @buffer = buffer
    end

    def __inline_templates_object; @object; end
 
    def ~
      @buffer.inlinetemplates_append @object
      @object
    end

    def method_missing(name, *args, &block)
      args.map! &BufferWrapper.method(:unwrap)
      block = BufferWrapper.create_proxy_proc(block, @buffer) unless block.nil?

      result = @object.__send__(name, *args, &block)

      return result if name.to_s == "to_str"

      BufferWrapper.wrap result, @buffer
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
      original_self = self

      proc do |*args, &block|
        unless @_inlinetemplates_context.nil?
          ::Kernel.puts "OH! block in context!"
        end

        args.map! { |arg| BufferWrapper.wrap arg, buffer }
        block = BufferWrapper.create_proxy_proc(block, buffer) unless block.nil?

        if self.equal? original_self
          nested.call *args, &block
        else
          buffer.inlinetemplates_instance_exec self, *args, &nested
        end
      end
    end
  end
end
