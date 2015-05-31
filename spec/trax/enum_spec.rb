require 'spec_helper'

describe ::Enum do
  subject do
    ::CategoryEnum
  end

  let(:expected_names) {  [:default, :clothing, :shoes, :accessories] }
  let(:expected_values) { [1,2,3,4] }

  describe ".key?" do
    it { subject.key?(:default).should eq true }
  end

  describe "[](val)" do
    it { subject[:default].to_i.should eq 1 }
  end

  describe "[](val)" do
    it { subject["default"].to_i.should eq 1 }
  end

  describe ".value?" do
    it { subject.value?(1).should eq true }
  end

  describe ".keys" do
    it { subject.keys.should eq [:default, :clothing, :shoes, :accessories] }
  end

  describe ".names" do
    it { subject.keys.should eq expected_names }
  end

  describe ".values" do
    it { subject.values.should eq expected_values }
  end

  context "duplicate enum name" do

    it { expect{subject.define_enum_value(:default, 6)}.to raise_error(::Trax::Core::Errors::DuplicateEnumValue) }
  end

  context "duplicate enum value" do
    it {expect{subject.define_enum_value(:newthing, 1)}.to raise_error(::Trax::Core::Errors::DuplicateEnumValue) }
  end

  context "InstanceMethods" do
    subject { ::CategoryEnum.new(:default) }

    it { subject.choice.should eq :default }
    it { subject.choice.should eq 1 }

    # its(:choice) { should eq :default }
    # it "choice changes" do
    #   binding.pry
    #   subject.choice = :clothing
    #   # subject.choice_was.should eq :default
    # end
  end
end
