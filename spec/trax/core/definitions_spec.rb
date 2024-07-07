require 'spec_helper'

describe ::Trax::Core::Definitions, :skip do
  subject(:definitions) { ::Defs }

  context "fields" do
    it { expect(subject[:category]).to eq subject::Category }
  end

  context "enum" do
    let(:test_subject) { subject::Category.new(1) }

    it { expect(test_subject).to be_a(::Trax::Core::Types::Enum) }
    it { expect(test_subject.name).to eq "Defs::Category::Default" }
  end

  context "struct" do
    it { expect(subject::ProductAttributes.new).to be_a(::Trax::Core::Types::Struct) }

    context "float" do
      it { expect(subject::ProductAttributes.new.price).to eq 9.99 }
      it { expect(subject::ProductAttributes.new(:price => 9).price).to eq 9.0 }
    end

    context "integer" do
      it { expect(subject::ProductAttributes.new.quantity_in_stock).to eq 0 }
      it { expect(subject::ProductAttributes.new(:quantity_in_stock => 9.19).quantity_in_stock).to eq 9 }
    end

    context "array" do
      it { expect(subject::ProductAttributes.new.categories.__getobj__).to be_a(::Array) }
      context "it instantiates members into objects if provided" do
        it { expect(subject::ProductAttributes.new(:categories => [ :clothing ]).categories[0].to_i).to eq 2 }
        it { expect(subject::ProductAttributes.new(:categories => [ 2 ]).categories[0].to_s).to eq "clothing" }
      end
    end

    context "set" do
      it { expect(subject::ProductAttributes.new.departments.__getobj__).to be_a(::Set) }
      context ".to_schema" do
        it { expect(subject::ProductAttributes.fields.to_schema[:departments][:attributes][:choices]).to eq ["mens", "womens"] }
      end
    end
  end

  context "inheritance" do
    it { expect(subject::ProductAttributes.new).to_not have_key(:size) }
    it { expect(subject::ShoesAttributes.new).to have_key(:size) }
    it { expect(subject::ShoesAttributes.new).to have_key(:price) }
    it { expect(subject::ShoesAttributes.new(:size => :mens_8).size.to_i).to eq 1 }
  end

  context "schema" do
    let(:schema) { definitions.to_schema }

    context "field defaults" do
      context "with defaults" do
        subject { schema[:shirt_attributes][:fields][field_name][:default] }

        context "string" do
          let(:field_name) { :name }
          it { is_expected.to eq("Three-Fifty") }
        end

        context "float" do
          let(:field_name) { :price }
          it { is_expected.to eq(3.50) }
        end

        context "integer" do
          let(:field_name) { :quantity_in_stock }
          it { is_expected.to eq(5) }
        end

        context "boolean" do
          let(:field_name) { :is_active }
          it { is_expected.to eq(true) }
        end

        context "array" do
          let(:field_name) { :categories }
          it { is_expected.to eq([:default, :clothing]) }
        end

        context "enum" do
          let(:field_name) { :size }
          it { is_expected.to eq(:womens_m) }
        end
      end

      context "without defaults" do
        subject { schema[:shipment_attributes][:fields][field_name] }

        context "string" do
          let(:field_name) { :tracking_number }
          it { is_expected.to_not have_key(:default) }
        end

        context "float" do
          let(:field_name) { :weight }
          it { is_expected.to_not have_key(:default) }
        end

        context "integer" do
          let(:field_name) { :insurance_amount }
          it { is_expected.to_not have_key(:default) }
        end

        context "boolean" do
          let(:field_name) { :is_insured }
          it { is_expected.to_not have_key(:default) }
        end

        context "array" do
          let(:field_name) { :notes }
          it { is_expected.to_not have_key(:default) }
        end

        context "enum" do
          let(:field_name) { :shipping_type }
          it { is_expected.to_not have_key(:default) }
        end
      end
    end
  end
end
