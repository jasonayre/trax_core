require 'spec_helper'

describe ::Trax::Core::Types::Enum do
  before(:all) do
    module MyFakeEnumNamespace
      extend ::Trax::Core::Definitions

      enum :Locale do
        define :en, 1
        define :da, 2
        define :ca, 3
      end

      enum :Category do
        define :misc, 1, :display_name => "Misc"
        define :clothing, 2, :display_name => "Clothing"
        define :shoes, 3, :display_name => "Shoes"
        define :accessories, 4, :display_name => "Accessories", :deprecated => true
      end

      enum :ExtendedCategory, :extends => "MyFakeEnumNamespace::Category" do
        define :watches,    5
        define :sunglasses, 6
      end
    end
  end

  subject { "::MyFakeEnumNamespace::Locale".constantize.new(:en) }

  it { expect(subject.to_i).to eq 1 }

  context "integer value" do
    subject { "::MyFakeEnumNamespace::Locale".constantize.new(1) }

    it { expect(subject).to eq :en }
  end

  context "non existent value" do
    subject { "::MyFakeEnumNamespace::Locale".constantize.new(:blah) }

    it { expect(subject).to eq nil }
  end

  context "category enum" do
    subject do
      "::MyFakeEnumNamespace::Category".constantize
    end

    let(:expected_names) {  [:misc, :clothing, :shoes, :accessories] }
    let(:expected_values) { [1,2,3,4] }

    describe ".key?" do
      it { expect(subject.key?(:misc)).to eq true }
    end

    describe "[](val)" do
      it { expect(subject[:misc].to_i).to eq 1 }
    end

    describe "[](val)" do
      it { expect(subject["misc"].to_i).to eq 1 }
    end

    describe ".value?" do
      it { expect(subject.value?(1)).to eq true }
    end

    describe ".keys" do
      it { expect(subject.keys).to eq [:misc, :clothing, :shoes, :accessories] }
    end

    describe ".names" do
      it { expect(subject.keys).to eq expected_names }
    end

    describe ".values" do
      it { expect(subject.values).to eq expected_values }
    end

    context "duplicate enum name" do
      it { expect{subject.define_enum_value(:misc, 6)}.to raise_error(::Trax::Core::Errors::DuplicateEnumValue) }
    end

    context "duplicate enum value" do
      it {expect{subject.define_enum_value(:newthing, 1)}.to raise_error(::Trax::Core::Errors::DuplicateEnumValue) }
    end

    context "InstanceMethods" do
      let(:described_object) do
        "::MyFakeEnumNamespace::Category".constantize
      end
      subject { described_object.new(:clothing) }

      it { expect(subject.choice).to eq :clothing }
      it { expect(subject.choice).to eq 2 }
      it { expect(subject.next_value.to_sym).to eq :shoes }
      it { expect(subject.previous_value.to_sym).to eq :misc }

      context "selection of values" do
        it { expect(subject.select_next_value).to eq described_object.new(:shoes).choice }
      end
      context "value is last" do
        subject { described_object.new(:accessories) }
        it { expect(subject.next_value?).to eq false }
        it { expect(subject.previous_value?).to eq true }

        context "selection of value" do
          it { expect(subject.select_next_value).to eq described_object.new(:accessories) }
          it { expect(subject.select_previous_value).to eq described_object.new(:shoes) }
        end
      end

      context "deprecated" do
        context "is deprecated" do
          subject { described_object.new(:accessories) }
          it { expect(subject.deprecated?).to be true }
        end

        context "not deprecated" do
          subject { described_object.new(:clothing) }
          it { expect(subject.deprecated?).to be false }
        end
      end
    end
  end

  context "inheritance" do
    let(:described_object) do
      "::MyFakeEnumNamespace::ExtendedCategory".constantize
    end

    it { expect(described_object.names).to include(:watches)}
    it { expect(described_object.new(:clothing).to_i).to eq 2 }
    it { expect(described_object.new(:watches).to_i).to eq 5 }

    context "does not mutate original hash" do
      let(:described_object) do
        "::MyFakeEnumNamespace::Category".constantize
      end

      let(:extended_object) do
        "MyFakeEnumNamespace::ExtendedCategory".constantize
      end

      it {
        expect(extended_object.names).to include(:watches)
        expect(described_object.names).to_not include(:watches)
        expect(extended_object.choices.length).to eq 6
        expect(described_object.choices.length).to eq 4
      }
    end
  end

  context "serialization" do
    context "it can be serialized" do
      let(:described_object) { "::MyFakeEnumNamespace::Category".constantize }
      subject { described_object.new(1) }
      it { expect{ Marshal.dump(subject) }.to_not raise_error }
    end

    context "it can be serialized when extended" do
      let(:described_object) { "::MyFakeEnumNamespace::ExtendedCategory".constantize }
      subject { described_object.new(1) }
      it { expect{ Marshal.dump(subject) }.to_not raise_error }
    end
  end

  context ".to_schema" do
    subject { "::MyFakeEnumNamespace::Category".constantize.to_schema }

    it { expect(subject).to have_key("choices") }
    it { expect(subject).to have_key("values") }

    context "enum value" do
      subject { "::MyFakeEnumNamespace::Category".constantize.new(2).to_schema }
      it { expect(subject[:attributes][:display_name]).to eq "Clothing" }
    end

    context "deprecated values" do
      it { expect(subject["values"]).to_not include(:accessories) }
      it { expect(subject["choices"].map(&["name"])).to_not include("accessories") }
    end
  end
end
