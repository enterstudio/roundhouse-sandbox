require 'rlet'
require 'shops'
class ChangeJob < ActiveJob::Base
  include Let
  queue_as :default

  def perform(n)
    n.times do
      shop_id = rand_shop['id']
      d = rand(100)

      # The first arg is the queue_id. The second arg is the arg
      if d < 80 then
        logger.info "Submitting update product"
        UpdateProductJob.perform_async(shop_id, shop_id)
      elsif d < 90 then
        logger.info "Submitting create product"
        FakeProductJob.perform_async(shop_id, shop_id)
      else
        logger.info "Submitting delete product"
        DeleteProductJob.perform_async(shop_id, shop_id)
      end
    end
  end

  def rand_shop
    Shops::SHOPS.sample
  end
end
