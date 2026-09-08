# frozen_string_literal: true

RSpec.describe Elelem::Skills::Skill do
  describe "#summary" do
    it "combines name and description" do
      skill = described_class.new("tdd", "desc", ".", "")

      expect(skill.summary).to eq("tdd: desc")
    end
  end
end
