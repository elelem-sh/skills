# frozen_string_literal: true

module Elelem
  module Skills
    Skill = Struct.new(:name, :description, :dir, :body) do
      def summary
        "#{name}: #{description}"
      end
    end
  end
end
