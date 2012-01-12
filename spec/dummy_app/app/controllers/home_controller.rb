class HomeController < ApplicationController
  def index
    @images = Image.find_all_by_is_featured(true)
    @categories = Category.all
  end
end
