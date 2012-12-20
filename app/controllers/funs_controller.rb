class FunsController < ApplicationController
  load_and_authorize_resource

  respond_to :html

  # GET /funs
  def index
    @funs = Fun.includes(:user, :content).filter_by_type(params[:type]).sorting(params[:sort], interval: params[:interval], sandbox: params[:sandbox]).page params[:page]
  end

  def tags
    funs_ids = ThinkingSphinx.search_for_ids(params[:tag], classes: [Fun])
    @funs = Fun.includes(:user, :content).where(id: funs_ids).filter_by_type(params[:type]).page params[:page]
    render 'index'
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
      redirect_to @fun, notice: 'Fun was successfully created.'
    else
      render "new"
    end
  end

  # PUT /funs/1
  def update
    if @fun.update_attributes(params[:fun])
      redirect_to @fun, notice: 'Fun was successfully updated.'
    else
      render action: "edit"
    end
  end

  # DELETE /funs/1
  def destroy
    @fun.destroy
    redirect_to funs_url
  end

  def repost
    flash[:notice] = @fun.repost_by current_user
    respond_to do |format|
      format.html {redirect_to @fun}
      format.js
    end
  end

  def like
    if current_user.voted_up_on? @fun
      @fun.unliked_by voter: current_user
    else
      @fun.liked_by current_user
    end
    respond_to do |format|
      format.html {redirect_to @fun, notice: 'Thanks for voting!'}
      format.js
    end
  end

  def likes
    @fun = Fun.find(params[:id]).likes.voters
    respond_to do |format|
      format.json {render json: @fun.as_json(:only => [:login, :avatar])}
    end
  end
end
