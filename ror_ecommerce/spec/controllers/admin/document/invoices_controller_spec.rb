require File.dirname(__FILE__) + '/../../../spec_helper'

describe Admin::Document::InvoicesController do
  render_views

  before(:each) do
    activate_authlogic

    @user = Factory(:admin_user)
    login_as(@user)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "show action should render show template" do
    invoice = Factory(:invoice)
    get :show, :id => invoice.id
    response.should render_template(:show)
  end

end
