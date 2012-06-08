require 'spec_helper'

describe "admin/history/addresses/show.html.erb" do
  before(:each) do
    @order = Factory(:order)
    @address =  Factory(:address)
  end

  it "renders attributes in <p>" do
    render :template => "admin/history/addresses/show", :handlers => [:erb]
  end
end
