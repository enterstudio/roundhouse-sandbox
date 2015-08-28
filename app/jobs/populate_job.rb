require 'rlet'
require 'shops'
class PopulateJob < ActiveJob::Base
  include Let
  queue_as :default

  def perform(n)
    n.times do
      shop_id = rand_shop['id']

      # The first arg is the queue_id. The second arg is the arg
      FakeProductJob.perform_async(shop_id, shop_id)
    end
  end

  def rand_shop
    Shops::SHOPS.sample
  end
end
