module Piggybak
  class Cart
    attr_accessor :items
    attr_accessor :total
    attr_accessor :errors
    attr_accessor :extra_data
  
    def initialize(cookie='')
      self.items = []
      self.errors = []
      cookie ||= ''
      cookie.split(';').each do |item|
	    item_product = Piggybak::Product.find_by_id(item.split(':')[0])
		if item_product.present?
	      self.items << { :product => item_product, :quantity => (item.split(':')[1]).to_i }
        end
      end
      self.total = self.items.sum { |item| item[:quantity]*item[:product].price }
    end
  
    def self.to_hash(cookie)
      cookie ||= ''
      cookie.split(';').inject({}) do |hash, item|
        hash[item.split(':')[0]] = (item.split(':')[1]).to_i
        hash
      end
    end
  
    def self.to_string(cart)
      cookie = ''
      cart.each do |k, v|
        cookie += "#{k.to_s}:#{v.to_s};" if v.to_i > 0
      end
      cookie
    end

    def self.add(cookie, params)
      cart = to_hash(cookie)
      cart["#{params[:product_id]}"] ||= 0
      cart["#{params[:product_id]}"] += params[:quantity].to_i
      to_string(cart)
    end
  
    def self.remove(cookie, product_id)
      cart = to_hash(cookie)
      cart[product_id] = 0
      to_string(cart)
    end
  
    def self.update(cookie, params)
      cart = to_hash(cookie)
      cart.each { |k, v| cart[k] = params[:quantity][k].to_i }
      to_string(cart)
    end
 
    def to_cookie
      cookie = ''
      self.items.each do |item|
        cookie += "#{item[:product].id.to_s}:#{item[:quantity].to_s};" if item[:quantity].to_i > 0
      end
      cookie
    end
  
    def update_quantities
      self.errors = []
      new_items = []
      self.items.each do |item|
        if item[:product].unlimited_inventory || item[:product].quantity >= item[:quantity]
          new_items << item
        else
          self.errors << ["Adjusting quantity for #{item[:product].description}"]
          item[:quantity] = item[:product].quantity
          new_items << item
        end
      end
      self.items = new_items
      self.total = self.items.sum { |item| item[:quantity]*item[:product].price }
    end
  end
end
