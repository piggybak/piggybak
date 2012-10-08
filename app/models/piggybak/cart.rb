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
        item_sellable = Piggybak::Sellable.find_by_id(item.split(':')[0])
        if item_sellable.present?
          self.items << { :sellable => item_sellable, :quantity => (item.split(':')[1]).to_i }
        end
      end
      self.total = self.items.sum { |item| item[:quantity]*item[:sellable].price }

      self.extra_data = {}
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
      cart["#{params[:sellable_id]}"] ||= 0
      cart["#{params[:sellable_id]}"] += params[:quantity].to_i
      to_string(cart)
    end
  
    def self.remove(cookie, sellable_id)
      cart = to_hash(cookie)
      cart[sellable_id] = 0
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
        cookie += "#{item[:sellable].id.to_s}:#{item[:quantity].to_s};" if item[:quantity].to_i > 0
      end
      cookie
    end
  
    def update_quantities
      self.errors = []
      new_items = []
      self.items.each do |item|
        if !item[:sellable].active
          self.errors << ["Sorry, #{item[:sellable].description} is no longer for sale"]
        elsif item[:sellable].unlimited_inventory || item[:sellable].quantity >= item[:quantity]
          new_items << item
        elsif item[:sellable].quantity == 0
          self.errors << ["Sorry, #{item[:sellable].description} is no longer available"]
        else
          self.errors << ["Sorry, only #{item[:sellable].quantity} available for #{item[:sellable].description}"]
          item[:quantity] = item[:sellable].quantity
          new_items << item if item[:quantity] > 0
        end
      end
      self.items = new_items
      self.total = self.items.sum { |item| item[:quantity]*item[:sellable].price }
    end

    def set_extra_data(form_params)
      form_params.each do |k, v|
        self.extra_data[k.to_sym] = v if ![:controller, :action].include?(k)
      end
    end
  end
end
