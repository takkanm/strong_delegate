# require "strong_delegate/version"

module StrongDelegate
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def def_delegate(delegate_class, &block)
      @delegate_class = delegate_class

      obj = Object.new
      obj.singleton_class.class_eval &block

      obj.singleton_methods.each do |method_name|
        m = obj.singleton_class.instance_method(method_name)
        delegate_methods[method_name] = m.parameters
      end
    end

    def delegate_class
      @delegate_class
    end

    def delegate_object_name
      @instance_variable_name
    end

    def delegate_methods
      @delegate_methods ||= {}
    end
  end

  def method_missing(name, *args, &block)
    @__delegate_object__ ||= self.class.delegate_class.new

    if self.class.delegate_methods.key?(name.to_sym)
      invoke_delegate_method!(name.to_sym, args, block)
    else
      super
    end
  end

  def invoke_delegate_method!(name, args, block)
    delegate_method = self.class.delegate_methods[name]

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

class Do
  include StrongDelegate

  def_delegate do
    def hoge1(a, *c, &b) end
    def hoge2(*a, c, &b) end
    def hoge3(a, c: 1, &b) end
  end
end

Do.new.hoge1(1, 3, 4, 5)
Do.new.hoge2(1, 3, 4, 5)
Do.new.hoge3(1, c: 1)
