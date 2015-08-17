require 'spec_helper'
require 'pry'

describe ::Trax::Core::TrackableProcEvaluation do
  subject { ClassesWithEvaluationTracking::A }

  it {
    binding.pry

  }
end
