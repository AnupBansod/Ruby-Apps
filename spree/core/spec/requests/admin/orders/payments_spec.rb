require 'spec_helper'

describe "Payments" do
  stub_authorization!

  before(:each) do

    reset_spree_preferences do |config|
      config.allow_backorders = true
    end

    Spree::Zone.delete_all
    shipping_method = create(:shipping_method, :zone => create(:zone, :name => 'North America')) 
    @order = create(:completed_order_with_totals, :number => "R100", :state => "complete",  :shipping_method => shipping_method) 
    product = create(:product, :name => 'spree t-shirt', :on_hand => 5)
    product.master.count_on_hand = 5
    product.master.save
    @order.add_variant(product.master, 2)
    @order.update!

    @order.inventory_units.each do |iu|
      iu.update_attribute_without_callbacks('state', 'sold')
    end
    @order.update!

  end

  context "payment methods" do

    before(:each) do
      create(:payment, :order => @order, :amount => @order.outstanding_balance, :payment_method => create(:bogus_payment_method, :environment => 'test'))
      visit spree.admin_path
      click_link "Orders"
      within('table#listing_orders tbody tr:nth-child(1)') { click_link "R100" }
    end

    it "should be able to list and create payment methods for an order", :js => true do

      click_link "Payments"
      within('#payment_status') { page.should have_content("Payment: balance due") }
      find('table.index tbody tr:nth-child(2) td:nth-child(2)').text.should == "$49.98"
      find('table.index tbody tr:nth-child(2) td:nth-child(3)').text.should == "Credit Card"
      find('table.index tbody tr:nth-child(2) td:nth-child(4)').text.should == "pending"

      click_button "Void"
      within('#payment_status') { page.should have_content("Payment: balance due") }
      page.should have_content("Payment Updated")
      find('table.index tbody tr:nth-child(2) td:nth-child(2)').text.should == "$49.98"
      find('table.index tbody tr:nth-child(2) td:nth-child(3)').text.should == "Credit Card"
      find('table.index tbody tr:nth-child(2) td:nth-child(4)').text.should == "void"

      click_on "New Payment"
      page.should have_content("New Payment") 
      click_button "Update"
      page.should have_content("successfully created!")

      click_button "Capture"
      within('#payment_status') { page.should have_content("Payment: paid") }
      page.should_not have_css('#new_payment_section')
    end

    # Regression test for #1269
    it "cannot create a payment for an order with no payment methods" do
      Spree::PaymentMethod.delete_all
      @order.payments.delete_all

      visit spree.new_admin_order_payment_path(@order)
      page.should have_content("You cannot create a payment for an order without any payment methods defined.")
      page.should have_content("Please define some payment methods first.")
    end

    # Regression tests for #1453
    context "with a check payment" do
      before do
        @order.payments.delete_all
        create(:payment, :order => @order,
                        :state => "checkout",
                        :amount => @order.outstanding_balance,
                        :payment_method => create(:bogus_payment_method, :environment => 'test'))
      end

      it "capturing a check payment from a new order" do
        visit spree.admin_order_payments_path(@order)
        click_button 'Capture'
        page.should_not have_content("Cannot perform requested operation")
        page.should have_content("Payment Updated")
      end

      it "voids a check payment from a new order" do
        visit spree.admin_order_payments_path(@order)
        click_button 'Void'
        page.should have_content("Payment Updated")
      end
    end

  end
end
