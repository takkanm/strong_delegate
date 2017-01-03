require "strong_delegate/version"

module StrongDelegate
  class InvalidInterfaceError < StandardError; end

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_reader :delegate_variable_name

    def def_delegate(delegate_variable_name = nil, &block)
      @delegate_variable_name = delegate_variable_name
      set_method_defines block
    end

    def delegate_to(delegate_variable_name)
      @delegate_variable_name = delegate_variable_name
    end

    def delegate_methods
      @delegate_methods ||= {}
    end

    private

    def set_method_defines(define_proc)
      obj = Object.new
      obj.singleton_class.class_eval &define_proc

      obj.singleton_methods.each do |method_name|
        m = obj.singleton_class.instance_method(method_name)
        delegate_methods[method_name] = m.parameters
      end
    end
  end

  private

  def method_missing(name, *args, &block)
    if respond_to_delegate_methods?(name)
      invoke_delegate_method!(name.to_sym, args, block)
    else
      super
    end
  end

  def respond_to_missing?(name, include_private = false)
    respond_to_delegate_methods?(name) || supper
  end

  def respond_to_delegate_methods?(name)
    self.class.delegate_methods.key?(name.to_sym)
  end

  def delegate_object
    instance_variable_get self.class.delegate_variable_name
  end

  def invoke_delegate_method!(name, args, block)
    object = delegate_object
    assert_delegate!(object, name.to_sym)

    object.public_send(name, *args, &block)
  end

  def assert_delegate!(object, name)
    return if object.method(name).parameters.map(&:first) == self.class.delegate_methods[name].map(&:first)
    raise StrongDelegate::InvalidInterfaceError
  end
end
