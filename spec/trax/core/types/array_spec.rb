require 'spec_helper'

describe ::Trax::Core::Types::Array do
  before(:all) do
    module AnotherFakeStructNamespace
      extend ::Trax::Core::Definitions
      struct :Widget do
        integer :height, :default => 0
        integer :width, :default => 0
      end
    end
  end

  subject { ::Trax::Core::Types::Array.of(::AnotherFakeStructNamespace::Widget) }

  context ".of" do
    let(:test_subject) { subject.new({:width => 1}) }
    it { test_subject[0].width.should eq 1 }
    it { test_subject[0].height.should eq 0 }

    context "does not duplicate values" do
      it {
        test_subject << {:width => 2, :height => 2}
        expect(test_subject.length).to eq 2
      }

      it {
        test_subject << {}
        test_subject << {}
        expect(test_subject.last.width).to eq 0
      }
    end
  end

  context "ArrayOf" do
    subject { ::Trax::Core::Types::ArrayOf[::AnotherFakeStructNamespace::Widget] }
    let(:test_subject) { subject.new({:width => 1}) }
    it { test_subject[0].width.should eq 1 }
    it { test_subject[0].height.should eq 0 }
  end
end
