class Shops
  KEY_FILE       = 'shopify_keys.yml'.freeze
  KEYS_FULL_PATH =  File.join(Rails.root, 'config', KEY_FILE).freeze
  SHOPS          = YAML.load_file(KEYS_FULL_PATH).freeze
  DB             = Hash[SHOPS.map { |s| [ s['id'].to_i, s ] }]
end
