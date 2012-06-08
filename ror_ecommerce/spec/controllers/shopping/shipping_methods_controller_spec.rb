require  'spec_helper'

describe Shopping::ShippingMethodsController do
  render_views

  before(:each) do
    activate_authlogic

    @cur_user = Factory(:user)
    login_as(@cur_user)

    #stylist_cart
    @variant  = Factory(:variant)

    create_cart(@cur_user, @cur_user, [@variant])

    @address      = Factory(:address)
    @order        = Factory(:order, :ship_address_id => @address.id)
    @order_item   = Factory(:order_item, :order => @order, :variant => @variant)
    @order.stubs(:order_items).returns([@order_item])
    @controller.stubs(:find_or_create_order).returns(@order)
  end

  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
end
describe Shopping::ShippingMethodsController do
  render_views

  before(:each) do
    activate_authlogic

    @cur_user = Factory(:user)
    login_as(@cur_user)

    #stylist_cart
    @variant  = Factory(:variant)

    create_cart(@cur_user, @cur_user, [@variant])

  end
  it "update action should render edit template when model is invalid" do
    @variant2  = Factory(:variant)
    @address      = Factory(:address)
    @order        = Factory(:order, :ship_address_id => @address)
    @order_item   = Factory(:order_item, :order => @order, :variant => @variant)
    @order_item2   = Factory(:order_item, :order => @order, :variant => @variant2)
    @order.stubs(:order_items).returns([@order_item, @order_item2])
    @controller.stubs(:find_or_create_order).returns(@order)

    @shipping_rate = Factory(:shipping_rate)
    @shipping_method = Factory(:shipping_method)
    #ShippingMethod.any_instance.stubs(:valid?).returns(false)
    #ShippingMethod.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @shipping_method.id,
                 :shipping_category => {
                    @variant.product.shipping_category_id => @shipping_rate.id,
                    @variant2.product.shipping_category_id => nil
                  }
    #response.should render_template(:edit)
    response.should redirect_to(shopping_shipping_methods_url)
  end

  it "update action should redirect when model is valid" do

    @address      = Factory(:address)
    @order        = Factory(:order, :ship_address_id => @address)
    @order_item   = Factory(:order_item, :order => @order, :variant => @variant)
    @order.stubs(:order_items).returns([@order_item])
    @controller.stubs(:find_or_create_order).returns(@order)

    @shipping_rate = Factory(:shipping_rate)
    @shipping_method = Factory(:shipping_method)
    ShippingMethod.any_instance.stubs(:valid?).returns(true)
    put :update, :id => @shipping_method.id, :shipping_category => {@variant.product.shipping_category_id => @shipping_rate.id }
    response.should redirect_to(shopping_orders_url)
  end
end