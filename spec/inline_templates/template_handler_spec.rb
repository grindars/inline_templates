require 'spec_helper'

describe InlineTemplates::TemplateHandler do
  it "renders" do
    invoke_controller(TestController, :test_file).should == TestController::ReferenceOutput
  end
end
