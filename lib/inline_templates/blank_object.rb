module InlineTemplates
  class BlankObject < BasicObject
    include ::Kernel

    def self.make_blank(*keep)
      old_verbose = $VERBOSE
      begin
        $VERBOSE = nil

        drop_methods [ :!, :!=, :==, :__id__, :__send__, :equal?, :instance_eval, :instance_exec ], keep
        drop_methods ::Kernel.instance_methods, keep
        drop_methods ::Kernel.private_instance_methods, keep

      ensure
        $VERBOSE = old_verbose
      end
    end

    def self.drop_methods(methods, keep)
      methods.each do |name|
        next if keep.include? name

        undef_method name
      end
    end
  end
end