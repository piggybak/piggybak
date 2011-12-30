module ApplicationHelper
  def cart_form(object)
    render "piggybak/cart/form", :object => object
  end
end
