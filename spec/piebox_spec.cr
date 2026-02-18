require "./spec_helper"

describe Piebox do
  it "has a version" do
    Piebox::VERSION.should_not be_nil
  end
end
