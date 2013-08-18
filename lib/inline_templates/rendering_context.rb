module InlineTemplates
  class RenderingContext < BasicObject
    def initialize(context, locals, builder)
      @_inlinetemplates_context = context
      @_inlinetemplates_locals = locals
      @_inlinetemplates_evaluating = true
      @_inlinetemplates_builder = builder
    end
 
    def P(obj)
      @_inlinetemplates_context.output_buffer.append = obj
    end
 
    def method_missing(name, *args, &block)
      args.map! &BufferWrapper.method(:unwrap)

      if @_inlinetemplates_locals.include?(name) && args.length == 0
        result = @_inlinetemplates_locals[name]
 
      elsif @_inlinetemplates_context.respond_to?(name, true)
        result = @_inlinetemplates_context.__send__ name, *args, &block
 
      elsif @_inlinetemplates_builder.can_build?(name)
        result = @_inlinetemplates_builder.build @_inlinetemplates_context, name, *args, &block
 
      else
        super
      end
 
      BufferWrapper.wrap result, @_inlinetemplates_context.output_buffer
    end
  end
end
