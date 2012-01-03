module ApplicationHelper
  def cart_form(object)
    render "piggybak/cart/form", :object => object
  end
  def cart_link
    cart = Piggybak::Cart.new(request.cookies["cart"]) 
    nitems = cart.items.inject(0) { |nitems, item| nitems + item[:quantity] }
    if nitems > 0
      link_to  "#{pluralize(nitems, 'item')}: #{number_to_currency(cart.total)}", piggybak.cart_url
    end
  end
  def orders_link(text)
    if current_user
      link_to text, piggybak.orders_list_url
    end
  end
end
