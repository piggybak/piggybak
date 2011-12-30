module Piggybak
  class CartController < ApplicationController
    def show
      @cart = Cart.new(cookies["cart"])
      @cart.update_quantities
      cookies["cart"] = { :value => @cart.to_cookie, :path => '/' }
    end
  
    def add
      cookies["cart"] = { :value => Cart.add(cookies["cart"], params), :path => '/' }
      redirect_to piggybak.cart_url
    end
  
    def remove
      response.set_cookie("cart", { :value => Cart.remove(cookies["cart"], params[:item]), :path => '/' })
      redirect_to piggybak.cart_url
    end
  
    def clear
      cookies["cart"] = { :value => '', :path => '/' }
      redirect_to piggybak.cart_url
    end
  
    def update
      cookies["cart"] = { :value => Cart.update(cookies["cart"], params), :path => '/' }
      redirect_to piggybak.cart_url
    end
  end
end
