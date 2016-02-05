require 'rlet'
require 'shops'
require 'shopify_faker/blueprints/fabrication'

class FakeProductJob
  include Roundhouse::Worker
  include Let

  CHAOS_MONKEY = 0

  attr_reader :shop_id, :product_id
  let(:shop)           { Shops::DB[shop_id] }
  let(:shopify_domain) { shop['shopify_domain'] }
  let(:api_key)        { shop['api_key'] }
  let(:password)       { shop['password'] }
  let(:shopify)        { ShopifyAPI::Metal::Session.connection shopify_domain, api_key: api_key, password: password, debug: true }

  let(:product_data)  { attributes_for(:shopify_product, id: nil, created_at: nil, updated_at: nil, published_at: nil, variants: [], images: [] ) }
  let(:variants_data) { Array.new(rand(3), &method(:generate_variant)) }
  let(:images_data)   { Array.new(rand(9) + 1, &method(:generate_image)) }

  def perform(shop_id)
    gc_log :start
    @shop_id = shop_id
    return unless shop.present?

    fail "Choas Monkey Strikes!" if CHAOS_MONKEY > 0 && rand(100) < CHAOS_MONKEY

    upload_product!
  ensure
    gc_log :end
    @__memoized=nil # Clear this out to release objects
    GC.start(full_mark: true, immediate_sweep: true)
    gc_log :after_gc
  end

  def upload_product!
    r = shopify.post('products.json', { product: product_data } )
    unless r.status == 201
      logger.error "Unable to create product. Aborting"
      ap r
      return false
    end
    @product_id = r.body['product']['id']
    _title      = r.body['product']['title']

    log "products/#{product_id} - #{_title}"
    # Cheat
    @images = images_data.map(&method(:upload_image!))
    variants_data.each(&method(:upload_variant!))
  end

  def upload_variant!(data)
    final_data = data.merge image_id: @images.sample['id']
    r = shopify.post("products/#{product_id}/variants.json", { variant: final_data } )

    unless r.status == 201 || r.status == 200
      logger.error "Unable to create variant. Aborting"
      return false
    end
    _id    = r.body['variant']['id']
    _title = r.body['variant']['title']

    log "products/#{product_id}/variants/#{_id} - #{_title}"
  end

  def upload_image!(data)
    r = shopify.post("products/#{product_id}/images.json", { image: data } )

    unless r.status == 201 || r.status == 200
      logger.error "Unable to create image. Aborting"
      ap r
      fail "Failed to create image"
    end

    _id  = r.body['image']['id']
    _src = r.body['image']['src']

    log "products/#{product_id}/images/#{_id} - #{_src}"
    r.body['image']
  end

  def log(msg)
    logger.info "[Generate #{shop_id}] #{msg}"
  end

  def gc_log(phase = nil)
    log "[#{phase}] LiveObj=#{GC.stat(:heap_live_slots)} OldObj=#{GC.stat(:old_objects)}"
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
