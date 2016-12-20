require "strong_delegate/version"

module StrongDelegate
  class InvalidInterfaceError < StandardError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_read :delegate_variable_name

    def def_delegate(delegate_variable_name = nil, &block)
      @delegate_variable_name = delegate_variable_name

      obj = Object.new
      obj.singleton_class.class_eval &block

      obj.singleton_methods.each do |method_name|
        m = obj.singleton_class.instance_method(method_name)
        delegate_methods[method_name] = m.parameters
      end
    end

    def assert_delegate!(delegate_class)
      delegate_methods.each do |method_name, parameters|
        method = delegate_class.instance_method(method_name)
        raise StrongDelegate::InvalidInterfaceError unless method.parameters == parameters
      end
    end

    def delegate_to(delegate_variable_name)
      @delegate_variable_name = delegate_variable_name
    end

    def delegate_methods
      @delegate_methods ||= {}
    end
  end

  def method_missing(name, *args, &block)
    if self.class.delegate_methods.key?(name.to_sym)
      invoke_delegate_method!(name.to_sym, args, block)
    else
      super
    end
  end

  def delegate_object
    instance_variable_get self.class.delegate_variable_name
  end

  def invoke_delegate_method!(name, args, block)
    object = delegate_object
    assert_delegate!(object, name.to_sym)

    object.public_send(*args, &block)
  end

  def assert_delegate!(object, name)
    return if object.method(name).parameters == self.class.delegate_methods[name]
    raise StrongDelegate::InvalidInterfaceError
  end
end
