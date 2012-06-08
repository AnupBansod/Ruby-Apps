require  'spec_helper'

describe Admin::Inventory::ReceivingsController do
  render_views

  before(:each) do
    activate_authlogic

    @user = Factory(:admin_user)
    login_as(@user)
    @purchase_order = Factory(:purchase_order)
  end

  it "show action should render show template" do
    get :show, :id => @purchase_order.id
    response.should render_template(:show)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end

  it "edit action should render edit template" do
    get :edit, :id => @purchase_order.id
    response.should render_template(:edit)
  end

  it "update action should render edit template when model is invalid" do
    PurchaseOrder.any_instance.stubs(:valid?).returns(false)
    put :update, :id => @purchase_order.id
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    PurchaseOrder.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @purchase_order.id
    response.should redirect_to(admin_inventory_receivings_url( :notice => 'Purchase order was successfully updated.'))
  end
end
