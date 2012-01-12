class PagesController < ApplicationController
  def show
    logger.warn "steph: #{params.inspect}"
    @page = Page.find_by_slug(params[:slug])

    if @page.nil?
      redirect_to root_url
    end
  end
end
