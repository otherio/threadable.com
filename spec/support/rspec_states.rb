module RSpec::States

  extend ActiveSupport::Concern

  module ClassMethods

    def define_state name, &block
      name = Regexp.new(Regexp.escape(name)) if name.is_a? String
      @defined_states ||= {}
      @defined_states[name] = block
    end

    def define_it_should name, &block
      name = %r{\A#{Regexp.escape(name)}\Z} if name.is_a? String
      @defined_it_should ||= {}
      @defined_it_should[name] = block
    end

    def defined_states
      @defined_states ||= {}
      super_defined_states = superclass.respond_to?(:defined_states) ?
        superclass.defined_states : {}
      super_defined_states.merge(@defined_states)
    end

    def defined_it_should
      @defined_it_should ||= {}
      super_defined_it_should = superclass.respond_to?(:defined_it_should) ?
        superclass.defined_it_should : {}
      super_defined_it_should.merge(@defined_it_should)
    end

    def find_defined_state name
      match_data = nil
      regexp, state_block = defined_states.find do |regexp, block|
        match_data = name.match(regexp)
      end
      state_block or raise ArgumentError, "unable to find a defined state that matches: #{name.inspect}"
      [match_data.to_a[1..-1], state_block]
    end

    def find_it_shoulds *shoulds
      shoulds.map do |it_string|
        match_data = nil
        _, it_block = defined_it_should.find do |it_regexp, it_block|
          match_data = it_string.match(it_regexp)
        end
        it_block or raise ArgumentError, "unable to find a defined it that matches: #{it_string}"
        [match_data.to_a[1..-1], it_block]
      end
    end

    def import_state *names
      names.each do |name|
        match_data, state_block = find_defined_state(name)
        class_exec(*match_data, &state_block)
      end
    end

    def state *names, &given_block
      context names.to_sentence do
        names.each do |name|
          match_data, state_block = find_defined_state(name)
          class_exec(*match_data, &state_block)
        end
        class_eval(&given_block) if given_block
      end
    end

    def it_should *shoulds
      name = shoulds.to_sentence
      it "it should #{name}" do
        it_should *shoulds
      end
    end

  end

  def it_should *shoulds
    self.class.find_it_shoulds(*shoulds).each do |match_data, it_block|
      instance_exec(*match_data, &it_block)
    end
  end

  RSpec.configure do |config|
    config.backtrace_exclusion_patterns += [/rspec_states/]
  end

end
