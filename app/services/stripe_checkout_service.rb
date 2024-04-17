class StripeCheckoutService
    def self.checkout(order, token)
      Rails.logger.info "StripeCheckoutService: Initiating checkout for Order ID: #{order.id}"
  
      begin
        # Create a charge on Stripe's servers - this will charge the user's card
        charge = Stripe::Charge.create({
          amount: (order.total * 100).to_i, # Amount in cents
          currency: 'cad',
          description: "Order ##{order.id}",
          source: token
        })
  
        Rails.logger.info "StripeCheckoutService: Stripe charge created with ID: #{charge.id}"
  
        unless charge.paid
          # Log the failure message from Stripe and raise an exception if the charge wasn't successful
          Rails.logger.error "StripeCheckoutService: Payment failed for Order ID: #{order.id}. Error: #{charge.failure_message}"
          raise Stripe::CardError.new(charge.failure_message)
        end
  
        # If payment was successful, update the order
        order.update(payment_status: 'paid', stripe_charge_id: charge.id)
        Rails.logger.info "StripeCheckoutService: Order ID: #{order.id} payment_status updated to 'paid'."
  
      rescue Stripe::CardError => e
        # If a Stripe error occurred, log it and re-raise the exception
        Rails.logger.error "StripeCheckoutService: Stripe::CardError - #{e.message}"
        raise
      rescue => e
        # Catch other unexpected errors, log them, and re-raise
        Rails.logger.error "StripeCheckoutService: Error processing payment - #{e.message}"
        raise
      end
    end
  end
  