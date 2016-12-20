require 'test/unit'
require 'strong_delegate'

class TestStrongDelegate < Test::Unit::TestCase
  sub_test_case 'define delegate class method' do
    class Human
      def run(shoes) end
    end

    class Cat
      def run() end
    end

    class Animal
      include StrongDelegate

      def_delegate :@species do
        def run(shoes) end
      end

      def initialize(species)
        @species  = species
      end
    end

    sub_test_case 'valid call' do
      setup do
        @subject = Animal.new(Human.new)
      end

      def test_valid_method_call
        assert_nothing_raised { @subject.run('new balance') }
      end
    end

    sub_test_case 'invalid call' do
      setup do
        @subject = Animal.new(Cat.new)
      end

      def test_valid_method_call
        assert_raise StrongDelegate::InvalidInterfaceError do
          @subject.run
        end
      end
    end
  end
end
