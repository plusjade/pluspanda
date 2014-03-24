config = MultiJson.load(Rails.root.join('config','stripe.json'))[Rails.env]

Rails.configuration.stripe = {
  :publishable_key => config["publishable_key"],
  :secret_key      => config["secret_key"]
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
