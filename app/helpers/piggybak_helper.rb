module PiggybakHelper
  def cart_form(object, options = {})
    render "piggybak/cart/form", :object => object, :locals => { :options => options }
  end
  def cart_link
    cart = Piggybak::Cart.new(request.cookies["cart"])
    nitems = cart.sellables.inject(0) { |nitems, item| nitems + item[:quantity] }
    if nitems > 0 && !["piggybak/orders", "piggybak/cart"].include?(params[:controller])
      link_to "#{pluralize(nitems, 'item')}: #{number_to_currency(cart.total)}", piggybak.cart_url
    end
  end
  def orders_link(text)
    if current_user
      link_to text, piggybak.orders_list_url
    end
  end
  def piggybak_track_order(store_name)
    if params[:controller] == "piggybak/orders" && params[:action] == "receipt" && session.has_key?(:last_order)
      render "piggybak/orders/google_analytics", :order => @order, :store_name => store_name
    end
  end
end
