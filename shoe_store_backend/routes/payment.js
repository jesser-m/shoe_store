const express = require('express');
const router = express.Router();
const Stripe = require('stripe');
const auth = require('../middleware/auth');

// Note: Ensure STRIPE_SECRET_KEY is in your .env file
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || 'sk_test_placeholder', {
  apiVersion: '2022-11-15',
});

// @route   POST api/payment/create-checkout-session
// @desc    Create a stripe checkout session (for Web)
// @access  Private
router.post('/create-checkout-session', auth, async (req, res) => {
  try {
    const { items, customerEmail, successUrl, cancelUrl } = req.body;

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: items.map(item => ({
        price_data: {
          currency: 'eur',
          product_data: {
            name: item.name,
            images: [item.imageUrl],
          },
          unit_amount: Math.round(item.price * 100),
        },
        quantity: item.quantity,
      })),
      mode: 'payment',
      customer_email: customerEmail,
      success_url: successUrl,
      cancel_url: cancelUrl,
    });

    res.json({ id: session.id, url: session.url });
  } catch (err) {
    console.error('Stripe Checkout Error:', err);
    res.status(500).json({ message: err.message });
  }
});

// @route   POST api/payment/create-payment-intent
// @desc    Create a payment intent (for Mobile)
// @access  Private
router.post('/create-payment-intent', auth, async (req, res) => {
  try {
    const { amount, currency, customerEmail } = req.body;

    // Create a PaymentIntent with the order amount and currency
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100), // Stripe expects amount in cents
      currency: currency || 'eur',
      receipt_email: customerEmail,
      automatic_payment_methods: {
        enabled: true,
      },
    });

    res.json({
      client_secret: paymentIntent.client_secret,
      id: paymentIntent.id,
      amount: amount,
      currency: currency || 'eur'
    });
  } catch (err) {
    console.error('Stripe error details:', err);
    res.status(500).json({ 
      message: 'Stripe Payment Error: ' + err.message, 
      error: err.message,
      type: err.type
    });
  }
});

module.exports = router;
