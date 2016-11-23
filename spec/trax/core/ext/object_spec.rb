require 'spec_helper'

describe ::Object do
  before(:all) do
    class SomeFakeClass < OpenStruct
    end
  end

  subject do
    SomeFakeClass
  end

  describe ".define_configuration_options" do
    before(:all) do
      class Shape < OpenStruct
        class_attribute :some_measurement
        self.some_measurement = 20

        define_configuration_options!(:dimensions) do
          option :size, :default => 0
          option :weight, :default => 10
          option :calculated, :default => lambda{ self.size + self.weight }
          option :calculated_with_context, :default => lambda{|context| self.calculated + context.some_measurement }
        end

        define_configuration_options(:geometry) do
          option :sides
          option :subtype
          option :vertices, :default => 10
        end

        configure_geometry do |config|
          config.sides = 0
        end

        def do_something(some_arg)
          some_arg
        end
      end

      class Square < Shape
        configure_geometry do |config|
          config.sides = 4
        end
      end

      class Triangle < Shape
        def do_something(*args)
          __smartsuper__(:do_something, *args)
        end
      end
    end

    subject { Shape }

    it { expect(subject::DimensionsConfiguration.new).to be_a(Trax::Core::Configuration) }
    it { expect(subject.dimensions_configuration.size).to eq 0 }
    it { expect(subject.dimensions_configuration.weight).to eq 10 }
    it { expect(subject.dimensions_configuration.calculated).to eq 10 }
    it { expect(subject.dimensions_configuration.calculated_with_context).to eq 30 }
    it { expect(subject.geometry_configuration.sides).to eq 0 }

    context "inheritance" do
      context "subclass calls configure" do
        subject { Square }

        it { expect(subject.geometry_configuration.sides).to eq 4 }
        it { expect(subject.geometry_configuration.vertices).to eq 10 }
      end

      context "subclass does not call configure" do
        subject { Triangle }

        it { expect(subject.geometry_configuration.sides).to eq 0 }
      end
    end
  end

  describe "#__smartsuper__" do
    subject { Triangle.new }
    it "calls super with any number of arguments" do
      expect(subject.do_something("one")).to eq "one"
    end
  end

  describe ".try_chain" do
    it "wraps multiple calls to try and calls try on return value" do
      expect(subject.try_chain(:name, :underscore)).to eq "some_fake_class"
    end

    it "handles return if nil is in chain" do
      expect(subject.try_chain(:name, :somefakemethod)).to be_nil
    end

    it "handles instances of class" do
      expect(SomeFakeClass.new.try_chain(:class, :name, :underscore)).to eq "some_fake_class"
    end
  end

  describe ".set_fully_qualified_constant" do
    it "sets a fully qualified constant" do
      result = Object.set_fully_qualified_constant("SomeFakeClass::SomeFakeNestedClass", Class.new)
      expect(result.name).to eq "SomeFakeClass::SomeFakeNestedClass"
    end

    it "raises error if no valid namespace to set constant upon is passed" do
      expect{Object.set_fully_qualified_constant("SomeFakeNestedClass", Class.new)}.to raise_error(StandardError)
    end
  end

  describe ".remove_instance_variables" do
    it "reset instance variables by symbol names" do
      obj = SomeFakeClass.new
      obj.instance_variable_set(:@someivar, "anything")
      obj.reset_instance_variables(:someivar)
      expect(obj.instance_variable_get(:@someivar)).to be nil
    end
  end
end
