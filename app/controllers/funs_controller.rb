class FunsController < ApplicationController
  load_and_authorize_resource

  respond_to :html

  # GET /funs
  def index
    @funs = Fun.includes(:user, :content).filter_by_type(params[:type]).sorting(params[:sort], interval: params[:interval], sandbox: params[:sandbox]).page params[:page]
  end

  def tags
    query = prepare_query params[:query]
    if query.nil?
      redirect_to funs_path
    else
      funs_ids = ThinkingSphinx.search_for_ids(query, classes: [Fun], :match_mode => :any)
      @funs = Fun.includes(:user, :content).where(id: funs_ids).filter_by_type(params[:type]).page params[:page]
      render 'index'
    end
  end

  def autocomplete_tags
    unless params[:tag].nil?
      tags = Fun.find_tags_by_name params[:tag]
      respond_to do |format|
        format.json { render :json => tags.collect { |tag| tag.name.to_s } }
      end
    end
  end

  def feed
    @funs = current_user.feed.includes(:user, :content).page params[:page]
    render 'index'
  end

  # GET /funs/1
  def show
    respond_to :html, :js
  end

  # GET /funs/new
  def new
  end

  # GET /funs/1/edit
  def edit
  end

  # POST /funs
  def create
    @fun = current_user.funs.new(params[:fun])
    if @fun.save
      redirect_to @fun, notice: t('funs.created')
    else
      render "new"
    end
  end

  # PUT /funs/1
  def update
    if @fun.update_attributes(params[:fun])
      redirect_to @fun, notice: t('funs.updated')
    else
      render "edit"
    end
  end

  # DELETE /funs/1
  def destroy
    @fun.destroy
    redirect_to funs_url, notice: t('funs.deleted')
  end

  def repost
    new_fun = @fun.repost_by current_user
    respond_to do |format|
      if new_fun.present?
        format.html { redirect_to new_fun, notice: t('funs.reposted') }
        format.json { render json: { message: t('funs.reposted'), type: "success" } }
      else
        format.html { redirect_to @fun, alert: t('funs.errors.repost') }
        format.json { render json: { message: t('funs.errors.repost'), type: "error" } }
      end
    end
  end

  # Shows 10 last users who reposted this fun
  def reposts
    users = Fun.find(params[:id]).reposts.limit(10).reposters
    respond_to do |format|
      format.json { render json: users.as_json(:only => [:login, :avatar]) }
    end
  end

  private

  # Prepare query for search by tag
  def prepare_query query
    if query.is_a? Array
      query.join(",")
    elsif query.is_a? String
      query
    else
      query.to_s
    end
  end

end
