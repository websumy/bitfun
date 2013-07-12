class SocialsController < ApplicationController
  before_filter :only_xhr_request

  def vkontakte_comments
    if check_sign params
      @fun = Fun.find(params[:id])
      @fun.update_attribute :comments_counter, params[:num]
      head :ok
    else
      head :bad_request
    end
  end

  def social_likes
    @fun = Fun.find(params[:id])
    render layout: false
  end

  private

  def check_sign(params)
      checkstr = Settings.widgets.vkontakte.comments.secret.to_s + params[:date].to_s + params[:num].to_s + params[:last_comment].to_s
      params[:sign].to_s == Digest::MD5.hexdigest(checkstr.encode('windows-1251'))
  end

end