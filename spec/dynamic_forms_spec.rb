require 'spec_helper'

describe DynamicForms do
  it "should be valid" do
    DynamicForms.should be_a(Module)
  end

  it "should have a configuration" do
    DynamicForms.configuration.should_not be_nil
  end
end
