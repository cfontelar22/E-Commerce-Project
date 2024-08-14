class StripeCheckoutService
  def self.create_charge(order, stripe_token)
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']

    begin
      charge = Stripe::Charge.create({
        amount: (order.total * 100).to_i,
        currency: 'cad',
        description: "Order ##{order.id} payment",
        source: stripe_token
      })

      if charge.paid
        order.update(status: 'paid', payment_id: charge.id)
        { success: true, payment_id: charge.id }
      else
        { success: false, error: charge.failure_message }
      end

    rescue Stripe::CardError => e
      { success: false, error: e.message }
    end
  end
end
