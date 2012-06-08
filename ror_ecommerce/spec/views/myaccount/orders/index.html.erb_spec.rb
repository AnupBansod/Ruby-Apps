require 'spec_helper'

describe "myaccount/orders/index.html.erb" do
  before(:each) do
    @orders = [
      Factory(:order),
      Factory(:order)
    ]
  end

  it "renders a list of myaccount_orders" do
    render :template => "myaccount/orders/index"
  end
end
