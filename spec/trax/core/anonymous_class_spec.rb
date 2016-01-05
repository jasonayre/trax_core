require 'spec_helper'

describe ::Trax::Core::AnonymousClass do
  let(:fake_klass_name) { "FakeNamespace::Something" }
  subject {
    described_class.new(:length => 5, :width => 10)
  }

  it { expect(subject.superclass).to eq ::Object }

  context "Created class accepts an options hash which defines its own attribute set at creation" do
    it { expect(subject.length).to eq 5 }
    it { expect(subject.width).to eq 10 }
  end

  context "inheritance" do
    subject{
      described_class.new(::String, :max_length => 10)
    }
    it { expect(subject.superclass).to eq ::String}
  end
end
