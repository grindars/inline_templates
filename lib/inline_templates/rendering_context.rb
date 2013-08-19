module InlineTemplates
  class RenderingContext < BlankObject
    make_blank :instance_exec, :instance_variable_set

    def initialize(context, locals, builder)
      @_inlinetemplates_context = context
      @_inlinetemplates_locals = locals
      @_inlinetemplates_evaluating = true
      @_inlinetemplates_builder = builder

      context.instance_variables.each do |var|
        instance_variable_set var, context.instance_variable_get(var)
      end
    end
 
    def t(obj)
      BufferWrapper.wrap obj.to_s, @_inlinetemplates_context.output_buffer
    end

    def h(obj)
      BufferWrapper.wrap obj.to_s.html_safe, @_inlinetemplates_context.output_buffer
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
