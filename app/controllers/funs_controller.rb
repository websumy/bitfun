class FunsController < ApplicationController
  before_filter :load_fun, except: [:index, :autocomplete_tags, :feed, :create, :new]
  authorize_resource

  respond_to :html

  # GET /funs
  def index

    type = params[:type] ||= cookies_store[:type]
    interval = params[:interval] ||= cookies_store[:interval]

    @funs = Fun.includes(:user, :content).filter_by_type(type).sorting(params[:sort], interval: interval, sandbox: params[:sandbox])

    if params[:query]
      funs_ids = Fun.search_fun_ids([params[:query]].flatten.join(','), type, params[:page])
      @funs = @funs.where(id: funs_ids)
    end

    cookies_store.set params.select { |k,v| k.in? %w(type view interval sort) }

    @funs = @funs.page params[:page]
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
    @funs = Fun.get_month_trends(current_user, cookies_store[:type])
    #@funs = @fun.get_related(current_user, cookies_store[:type])
    respond_to :html, :js
  end

  # GET /funs/new
  def new
    @fun = Fun.new
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

  private
  def load_fun
    @fun = Fun.without_reposts.find(params[:id])
  end
end
