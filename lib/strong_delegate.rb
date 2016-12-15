# require "strong_delegate/version"

module StrongDelegate
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def def_delgate(&block)
      obj = Object.new
      obj.singleton_class.class_eval &block

      obj.singleton_methods.each do |mn|
        m = obj.singleton_class.instance_method(mn)
        p m.parameters
      end
    end

    def delegate(instance_variable_name)
      @instance_variable_name = instance_variable_name
    end

    def delegate_object_name
      @instance_variable_name
    end

    def delegate(method_name, arity: 0, block: false)
      @delegate_methods ||= {}
      @delegate_methods[method_name.to_sym] = {arity: arity, block: false}
    end

    def delegate_methods
      @delegate_methods
    end
  end

  def method_missing(name, *args, &block)
    if self.class.delegate_method.key?(name.to_sym)
      invoke_delegate_method!(name.to_sym, args, block)
    else
      super
    end
  end

  def invoke_delegate_method!(name, args, block)
    delegate_method = self.class.delegate_method[name]

    assert_arity!(delegate_method[:arity], args)
    assert_block!(delegate_method, block)

    object = instance_variable_get(self.class.delegate_object_name)
    object.public_send(*args, &block)
  end

  def assert_arity!(arity, args)
    return if arity < 0
    raise unless block_given == args.size
  end

  def assert_arity(block_given, block)
    return if block_given.nil?
    raise unless block_given == !!(block_given)
  end
end
