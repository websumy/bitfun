class SocialsController < ApplicationController
  before_filter :only_xhr_request

  def social_likes
    @fun = Fun.unscoped.find(params[:id])
    render layout: false
  end
end