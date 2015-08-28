require 'rlet'
require 'shops'
require 'shopify_faker/blueprints/fabrication'

class FakeProductJob
  include Roundhouse::Worker
  include Let

  attr_reader :shop_id
  let(:shop)           { Shops::DB[shop_id] }
  let(:shopify_domain) { shop['shopify_domain'] }
  let(:api_key)        { shop['api_key'] }
  let(:password)       { shop['password'] }

  let(:site) { "https://#{api_key}:#{password}@#{shopify_domain}" }

  let(:product)       { ShopifyAPI::Product.new(product_data) }
  let(:product_data)  { attributes_for(:shopify_product, id: nil, created_at: nil, updated_at: nil, published_at: nil, variants: [], images: [] ) }
  let(:variants_data) { Array.new(rand(3), &method(:generate_variant)) }
  let(:images_data)   { Array.new(rand(9) + 1, &method(:generate_image)) }

  def perform(shop_id)
    @shop_id = shop_id
    return unless shop.present?

    with_shopify_site do
      upload_product!
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

  def upload_product!
    product.save!
    log "products/#{product.id} - #{product.title}"
    # Cheat
    @images = images_data.map(&method(:upload_image!))
    variants_data.each(&method(:upload_variant!))
  end

  def upload_variant!(data)
    var = ShopifyAPI::Variant.new(data)
    var.prefix_options = { product_id: product.id }
    var.image_id = @images.sample.id
    var.save!
    log "products/#{product.id}/variants/#{var.id} - #{var.title}"
  end

  def upload_image!(data)
    img = ShopifyAPI::Image.new(data)
    img.prefix_options = { product_id: product.id }
    img.save!
    log "products/#{product.id}/images/#{img.id} - #{img.src}"
    img
  end

  def log(msg)
    logger.info "[Generate #{shop_id}] #{msg}"
  end

  def generate_variant(_)
    attributes_for(:shopify_variant, id: nil, created_at: nil, published_at: nil)
  end

  def generate_image(_)
    attributes_for(:shopify_image, id: nil, created_at: nil, published_at: nil, position: nil, variant_ids: [], src: rand_image_url)
  end

  def rand_image_url
    "http://loremflickr.com/320/240?random=#{SecureRandom.urlsafe_base64}"
  end

  def attributes_for(*args)
    Fabricate.attributes_for(*args)
  end
end
