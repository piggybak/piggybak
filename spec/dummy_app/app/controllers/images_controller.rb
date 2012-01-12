class ImagesController < ApplicationController
  def show
    @image = Image.find_by_slug(params[:id])

    if @image.nil?
      image = Image.find_by_id(params[:id])
      if image
        redirect_to image_url(image.slug), :status => 301
      else
        redirect_to root_url
      end
    else
      if @image.categories.any?
        @related_images = @image.categories.first.images.select { |p| p != @image }[0..2]
      else
        @related_images = []
      end
    end
  end
end
