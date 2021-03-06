module RSpec
  module Expectations
    # @api private
    # Provides methods for enabling and disabling the available
    # syntaxes provided by rspec-expectations.
    module Syntax
      extend self

      # @method should
      # Passes if `matcher` returns true.  Available on every `Object`.
      # @example
      #   actual.should eq expected
      #   actual.should match /expression/
      # @param [Matcher]
      #   matcher
      # @param [String] message optional message to display when the expectation fails
      # @return [Boolean] true if the expectation succeeds (else raises)
      # @see RSpec::Matchers

      # @method should_not
      # Passes if `matcher` returns false.  Available on every `Object`.
      # @example
      #   actual.should_not eq expected
      # @param [Matcher]
      #   matcher
      # @param [String] message optional message to display when the expectation fails
      # @return [Boolean] false if the negative expectation succeeds (else raises)
      # @see RSpec::Matchers

      # @method expect
      # Supports `expect(actual).to matcher` syntax by wrapping `actual` in an
      # `ExpectationTarget`.
      # @example
      #   expect(actual).to eq(expected)
      #   expect(actual).to_not eq(expected)
      # @return [ExpectationTarget]
      # @see ExpectationTarget#to
      # @see ExpectationTarget#to_not

      # @api private
      # Determines where we add `should` and `should_not`.
      def default_should_host
        @default_should_host ||= Object.ancestors.last
      end

      # @api private
      # Enables the `should` syntax.
      def enable_should(syntax_host = default_should_host)
        return if should_enabled?(syntax_host)

        syntax_host.module_eval do
          def should(matcher=nil, message=nil, &block)
            ::RSpec::Expectations::PositiveExpectationHandler.handle_matcher(self, matcher, message, &block)
          end

          def should_not(matcher=nil, message=nil, &block)
            ::RSpec::Expectations::NegativeExpectationHandler.handle_matcher(self, matcher, message, &block)
          end
        end
      end

      # @api private
      # Disables the `should` syntax.
      def disable_should(syntax_host = default_should_host)
        return unless should_enabled?(syntax_host)

        syntax_host.module_eval do
          undef should
          undef should_not
        end
      end

      # @api private
      # Enables the `expect` syntax.
      def enable_expect(syntax_host = ::RSpec::Matchers)
        return if expect_enabled?(syntax_host)

        syntax_host.module_eval do
          def expect(*target, &target_block)
            target << target_block if block_given?
            raise ArgumentError.new("You must pass an argument or a block to #expect but not both.") unless target.size == 1
            ::RSpec::Expectations::ExpectationTarget.new(target.first)
          end
        end
      end

      # @api private
      # Disables the `expect` syntax.
      def disable_expect(syntax_host = ::RSpec::Matchers)
        return unless expect_enabled?(syntax_host)

        syntax_host.module_eval do
          undef expect
        end
      end

      # @api private
      # Indicates whether or not the `should` syntax is enabled.
      def should_enabled?(syntax_host = default_should_host)
        syntax_host.method_defined?(:should)
      end

      # @api private
      # Indicates whether or not the `expect` syntax is enabled.
      def expect_enabled?(syntax_host = ::RSpec::Matchers)
        syntax_host.method_defined?(:expect)
      end
    end
  end
end
