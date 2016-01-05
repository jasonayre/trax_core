require 'spec_helper'

describe ::Trax::Core::Types::AnonymousStruct do
  ::Object.const_set("MyFakeLocationStructKlass", ::Trax::Core::AnonymousClass.new(::Trax::Core::Types::AnonymousStruct) do
    string :region

    anonymous_enum :continent do
      define :north_america, 1
      define :south_america, 2
      define :Europe,        3
      define :Asia,          4
    end

    time :created_at
    time :last_updated_at, :default => lambda{|record| ::Time.mktime(1980,1,1) }

    float :latitude, :default => 1.0
    float :longitude, :default => 5.0

    set :place_ids
    set :lat_long_with_sum, :default => lambda{|record| [ record.latitude, record.longitude, (record.latitude + record.longitude) ] }
  end)

  let!(:location_struct_klass) { ::Object.const_get("MyFakeLocationStructKlass") }

  let!(:locale_struct_klass) do
    ::Trax::Core::AnonymousClass.new(described_class) do
      string :en, :default => ""
      string :da, :default => ""
      string :ca, :default => "eh"

      anonymous_struct :territories do
        string :en, :default => "US"
      end

      array :locations, :of => "MyFakeLocationStructKlass"

      boolean :is_whatever, :default => true

      json :phone_formats
      json :date_formats, :default => {:en_US => "%m-%d-%y"}
    end
  end

  subject { locale_struct_klass.new(:en => "something") }

  let!(:fake_time1) {
    @fake_time1 = ::Time.stub(:now).and_return(::Time.mktime(1970,1,1))
  }
  let!(:fake_time2) {
    @fake_time2 = ::Time.stub(:now).and_return(::Time.mktime(1971,1,1))
  }

  it { expect(subject).to have_key("en") }
  it { expect(subject.en).to eq "something" }
  it { expect(subject.da).to eq "" }
  it { expect(subject.ca).to eq "eh" }

  it { expect(subject.territories.en).to eq "US" }

  it { expect(subject.phone_formats).to eq({}) }
  it { expect(subject.date_formats).to eq('en_US' => "%m-%d-%y") }

  context "unknown value" do
    subject { locale_struct_klass.new(:blah => "something") }
    it { expect(subject).to_not respond_to(:blah) }
    it { expect(subject.en).to eq "" }
  end

  context "with json property" do
    let(:locale) { :en_GB }
    let(:date_format) { "%d/%m/%Y" }
    let(:definition){ locale_struct_klass.new(:date_formats => {locale => date_format}) }
    subject { definition.date_formats }

    it { expect(subject[locale.to_s]).to eq date_format }
    it { expect(subject[locale.to_sym]).to eq date_format }
  end

  context "with array_of property", :focus => true do
    let(:definition) { locale_struct_klass.new(:locations => [{:continent => :asia}]) }

    subject { definition }
    it { expect(definition.locations.first.continent.to_i).to eq(4) }

    context "casts to empty array" do
      let(:definition) { locale_struct_klass.new }
      it { expect(definition.locations.length).to eq 0 }
      it { expect(definition.locations).to_not eq nil }
    end
  end

  context "with set property" do
    let(:definition) { location_struct_klass.new(:place_ids => [1, 2]) }

    subject { definition }
    it { expect(definition.place_ids.first).to eq(1) }

    context "behaves like a set" do
      it {
        subject.place_ids << 1
        subject.place_ids << 1
        expect(subject.place_ids.length).to eq 2
      }
    end

    context "default value" do
      it {
        expect(subject.lat_long_with_sum).to eq [1.0, 5.0, 6.0].to_set
      }
    end
  end

  context "with boolean property" do
    let(:definition) { locale_struct_klass }
    subject { definition.new(:is_whatever => false) }

    it { expect(subject.is_whatever).to eq false }
    context "default" do
      subject { definition.new }
      it{ expect(subject.is_whatever).to eq true }
    end

    context "coercion" do
      subject { definition.new(:is_whatever => '') }
      it{ expect(subject.is_whatever).to eq false }
      it{ expect(subject.is_whatever).to be_falsey }
    end
  end

  context "with time property" do
    let(:definition) { location_struct_klass }
    subject { definition.new(:created_at => fake_time1) }
    it { expect(subject.created_at).to eq fake_time1 }

    context "parsing timestamps" do
      let(:db_timestamp) { "2015-12-05 15:34:57.701289" }
      let(:test_subject) { definition.new(:created_at => db_timestamp) }
      it { test_subject.created_at.should be_a(::Time) }
    end

    context "default value" do
      subject{ definition.new }
      it { expect(subject.last_updated_at).to eq ::Time.mktime(1980,1,1) }
    end
  end
end
