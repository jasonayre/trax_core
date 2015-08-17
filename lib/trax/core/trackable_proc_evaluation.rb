module Trax
  module Core
    module TrackableProcEvaluation
      def self.extended(base)
        base.instance_variable_set("@evaluation_registry", {})

      end

      def call(*args)
        puts binding
        puts args

        binding.pry
      end
    end
  end
end
