require 'spec_helper'

describe InlineTemplates::Helpers do
  it "defines helper" do
    invoke_controller(TestController, :test).should == TestController::ReferenceOutput
  end
end
