module ClassesWithEvaluationTracking
  class A
    class_attribute :blocks_that_do_stuff
    self.blocks_that_do_stuff = []

    def self.do_something(&block)
      self.blocks_that_do_stuff << block.extend(::Trax::Core::TrackableProcEvaluation)
      # blocks_that_do_stuff << ::Trax::Traits.for(block)[:track_evaluation]
    end

    do_something do

    end
  end

  class B < A
    do_something do

    end
  end
end
