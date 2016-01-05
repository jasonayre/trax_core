require 'spec_helper'

describe ::Trax::Core::Types::AnonymousEnum do
  let(:locale_enum_klass){
    ::Trax::Core::AnonymousClass.new(described_class) do
      define :en, 1
      define :da, 2
      define :ca, 3
    end
  }
  let(:category_enum_klass) {
    ::Trax::Core::AnonymousClass.new(described_class) do
      define :default, 1
      define :clothing, 2
      define :shoes, 3
      define :accessories, 4
    end
  }

  subject { locale_enum_klass.new(:en) }
  it{ expect(subject.to_i).to eq 1 }
  context "integer value" do
    it { expect(subject).to eq :en }
  end

  context "non existent value" do
    subject { locale_enum_klass.new(:blah) }

    it { expect(subject).to eq nil }
  end

  context "category enum" do
    subject do
      category_enum_klass
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
      let(:described_object) do
        category_enum_klass
      end
      subject { described_object.new(:clothing) }

      it { subject.choice.should eq :clothing }
      it { subject.choice.should eq 2 }
      it { expect(subject.next_value.to_sym).to eq :shoes }
      it { expect(subject.previous_value.to_sym).to eq :default }

      context "selection of values" do
        it { subject.select_next_value.should eq described_object.new(:shoes).choice }
      end
      context "value is last" do
        subject { described_object.new(:accessories) }
        it { subject.next_value?.should eq false }
        it { subject.previous_value?.should eq true }

        context "selection of value" do
          it { expect(subject.select_next_value).to eq described_object.new(:accessories) }
          it { expect(subject.select_previous_value).to eq described_object.new(:shoes) }
        end
      end
    end
  end
end
