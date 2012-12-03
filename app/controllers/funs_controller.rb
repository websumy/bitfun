class FunsController < ApplicationController
  load_and_authorize_resource

  before_filter :increment_shows, :only => [:show]

  respond_to :html

  # GET /funs
  def index
    @funs = Fun.includes(:user, :content).sort_by_type(params[:type]).sorting(params[:sort], params[:interval]).page params[:page]
  end

  def feed
    @funs = current_user.feed.includes(:user, :content).page params[:page]
    render 'index'
  end

  # GET /funs/1
  def show
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
      render action: "new"
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
    current_fun = Fun.find(params[:id])
    if current_fun.user != current_user
      @fun = current_fun.dup
      @fun.user = current_user
      redirect_to @fun, notice: 'Fun was successfully created.' if @fun.save
    else
      redirect_to funs_url, notice: "Can't do repost!"
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

  private
  def increment_shows
    @fun.increment! :cached_shows
  end
end
