module Piggybak
  class CartController < ApplicationController
    def show
      @cart = Cart.new(request.cookies["cart"])
    end
  
    def add
      cookies["cart"] = { :value => Cart.add(request.cookies["cart"], params), :path => '/' }
      redirect_to piggybak.cart_url
    end
  
    def remove
      response.set_cookie("cart", { :value => Cart.remove(request.cookies["cart"], params[:item]), :path => '/' })
      redirect_to piggybak.cart_url
    end
  
    def clear
      cookies["cart"] = { :value => '', :path => '/' }
      redirect_to piggybak.cart_url
    end
  
=begin  
    def update
      response.set_cookie("cart", { :value => Cart.update(request.cookies["cart"], params), :path => '/' })
      redirect_to cart_url
    end
=end
  end
end
