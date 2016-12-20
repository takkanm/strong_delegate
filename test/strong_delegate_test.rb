require 'test/unit'
require 'strong_delegate'

class TestStrongDelegate < Test::Unit::TestCase
  sub_test_case 'define delegate class method' do
    class ValidToClass
      def delegatable_method(a, *c, &b) end
    end

    class InvalidToClass
      def delegatable_method(a, &b) end
    end

    class DelegateClass
      include StrongDelegate

      def_delegate :@to do
        def delegatable_method(a, *c, &b) end
      end

      def initialize(to)
        @to = to
      end
    end

    sub_test_case 'valid call' do
      setup do
        @subject = DelegateClass.new(ValidToClass.new)
      end

      def test_valid_method_call
        assert_nothing_raised { @subject.delegatable_method(1, 3) { true } }
      end
    end

    sub_test_case 'invalid call' do
      setup do
        @subject = DelegateClass.new(InvalidToClass.new)
      end

      def test_valid_method_call
        assert_raise StrongDelegate::InvalidInterfaceError do
          @subject.delegatable_method(1) { true }
        end
      end
    end
  end
end
