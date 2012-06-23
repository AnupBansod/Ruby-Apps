module Spree
  class Payment < ActiveRecord::Base
    include Spree::Payment::Processing
    belongs_to :order, :class_name => "Spree::Order"
    belongs_to :source, :polymorphic => true, :validate => true
    belongs_to :payment_method, :class_name => "Spree::PaymentMethod"

    has_many :offsets, :class_name => "Spree::Payment", :foreign_key => :source_id, :conditions => "source_type = 'Spree::Payment' AND amount < 0 AND state = 'completed'"
    has_many :log_entries, :as => :source

    after_save :create_payment_profile, :if => :profiles_supported?

    # update the order totals, etc.
    after_save :update_order

    attr_accessor :source_attributes
    after_initialize :build_source

    attr_accessible :amount, :payment_method_id, :source_attributes

    scope :from_credit_card, where(:source_type => 'Spree::CreditCard')
    scope :with_state, lambda { |s| where(:state => s) }
    scope :completed, with_state('completed')
    scope :pending, with_state('pending')
    scope :failed, with_state('failed')

    # order state machine (see http://github.com/pluginaweek/state_machine/tree/master for details)
    state_machine :initial => 'checkout' do
      # With card payments, happens before purchase or authorization happens
      event :started_processing do
        transition :from => ['checkout', 'pending', 'completed', 'processing'], :to => 'processing'
      end
      # When processing during checkout fails
      event :failure do
        transition :from => 'processing', :to => 'failed'
      end
      # With card payments this represents authorizing the payment
      event :pend do
        transition :from => ['checkout', 'processing'], :to => 'pending'
      end
      # With card payments this represents completing a purchase or capture transaction
      event :complete do
        transition :from => ['processing', 'pending', 'checkout'], :to => 'completed'
      end
      event :void do
        transition :from => ['pending', 'completed', 'checkout'], :to => 'void'
      end
    end

    def offsets_total
      offsets.map(&:amount).sum
    end

    def credit_allowed
      amount - offsets_total
    end

    def can_credit?
      credit_allowed > 0
    end

    # see https://github.com/spree/spree/issues/981
    def build_source
      return if source_attributes.nil?
      if payment_method and payment_method.payment_source_class
        self.source = payment_method.payment_source_class.new(source_attributes)
      end
    end

    def actions
      return [] unless payment_source and payment_source.respond_to? :actions
      payment_source.actions.select { |action| !payment_source.respond_to?("can_#{action}?") or payment_source.send("can_#{action}?", self) }
    end

    def payment_source
      res = source.is_a?(Payment) ? source.source : source
      res || payment_method
    end

    private
      def amount_is_valid_for_outstanding_balance_or_credit
        return unless order
        if amount != order.outstanding_balance
          errors.add(:amount, "does not match outstanding balance (#{order.outstanding_balance})")
        end
      end

      def profiles_supported?
        payment_method.respond_to?(:payment_profiles_supported?) && payment_method.payment_profiles_supported?
      end

      def create_payment_profile
        return unless source.is_a?(CreditCard) && source.number && !source.has_payment_profile?
        payment_method.create_profile(self)
      rescue ActiveMerchant::ConnectionError => e
        gateway_error e
      end

      def update_order
        order.payments.reload
        order.update!
      end
  end
end
