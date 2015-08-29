require 'rlet'
require 'shops'
require 'shopify_faker/blueprints/fabrication'

class UpdateProductJob
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
      update_random_product!
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

  def update_random_product!
    case rand(3)
      when 0 then
        case rand(5)
        when 0 then product.title = product_title
        when 1 then product.product_type = product_type
        when 2 then product.vendor = vendor
        when 3 then product.handle = handle
        end
        log "products/#{product.id} - #{product.title}"
        product.save!
    when 1 then
      img = product.images.sample
      img.position = rand(10)
      img.save!
      log "products/#{product.id}/images/#{img.id} - position: #{img.position}"
    when 2 then
      var = product.variants.sample
      var.title = variant_title
      var.save!
      log "products/#{product.id}/variants/#{var.id} - title: #{var.title}"
    end
  end

  def log(msg)
    logger.info "[Update #{shop_id}] #{msg}"
  end

end
