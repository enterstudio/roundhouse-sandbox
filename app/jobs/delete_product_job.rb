require 'rlet'
require 'shops'
require 'shopify_faker/blueprints/fabrication'

class DeleteProductJob
  include Roundhouse::Worker
  include Let
  include ShopifyFaker::RSpec::Fabrication

  CHAOS_MONKEY = 0

  attr_reader :shop_id
  let(:shop)           { Shops::DB[shop_id] }
  let(:shopify_domain) { shop['shopify_domain'] }
  let(:api_key)        { shop['api_key'] }
  let(:password)       { shop['password'] }

  let(:site) { "https://#{api_key}:#{password}@#{shopify_domain}/admin" }

  let(:products)      { ShopifyAPI::Product.all }
  let(:product)       { products.sample }

  def perform(shop_id)
    @shop_id = shop_id
    return unless shop.present?

    fail "Choas Monkey Strikes!" if CHAOS_MONKEY > 0 && rand(100) < CHAOS_MONKEY

    with_shopify_site do
      log "products/#{product.id} - #{product.title}"
      product.destroy
    end
  end

  def with_shopify_site(&block)
    #ShopifyAPI::Session.temp(site, '', &block)
    original = ShopifyAPI::Base.site

    ShopifyAPI::Base.site = site
    ShopifyAPI::Base.headers.delete('X-Shopify-Access-Token')
    yield
    ShopifyAPI::Base.site = original
  end

  def log(msg)
    logger.info "[Delete #{shop_id}] #{msg}"
  end

end
