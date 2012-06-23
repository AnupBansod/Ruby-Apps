module Spree
  module Api
    module V1
      class PaymentsController < Spree::Api::V1::BaseController
        before_filter :find_order
        before_filter :find_payment, :only => [:show, :authorize, :purchase, :capture, :void, :credit]

        def index
          @payments = @order.payments
        end

        def new
          @payment_methods = Spree::PaymentMethod.where(:environment => Rails.env)
        end

        def create
          @payment = @order.payments.build(params[:payment])
          if @payment.save
            render :show, :status => 201
          else
            invalid_resource!(@payment)
          end
        end

        def show
        end

        def authorize
          perform_payment_action(:authorize)
        end

        def purchase
          perform_payment_action(:purchase)
        end

        def void
          perform_payment_action(:void_transaction)
        end

        def credit
          if params[:amount].to_f > @payment.credit_allowed
            render "spree/api/v1/payments/credit_over_limit", :status => 422
          else
            perform_payment_action(:credit, params[:amount])
          end
        end

        private

        def find_order
          @order = Order.find_by_number(params[:order_id])
          authorize! :read, @order
        end

        def find_payment
          @payment = @order.payments.find(params[:id])
        end

        def perform_payment_action(action, *args)
          authorize! action, Payment

          begin
            @payment.send("#{action}!", *args)
            render :show
          rescue Spree::Core::GatewayError => e
            @error = e.message
            render "spree/api/v1/errors/gateway_error", :status => 422
          end
        end
      end
    end
  end
end
