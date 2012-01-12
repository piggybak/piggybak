class CategoriesController < ApplicationController
  def show
    @category = Category.find_by_slug(params[:id])

    if @category.nil?
      redirect_to root_url
    end
  end
end
