class FunsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :destroy
  skip_authorize_resource only: :autocomplete_tags
  respond_to :html
  before_filter :only_xhr_request, only: [:new, :autocomplete_tags]
  before_filter :load_users, only: [:index, :feed]

  # GET /funs
  def index
    @funs = Fun.includes(:user, :content).filter_by_type(type).sorting(params[:sort], interval: interval, sandbox: params[:sandbox])

    if params[:query]
      funs_ids = Fun.search_fun_ids(params[:query], type)
      @funs = @funs.where(id: funs_ids)
    end

    cookies_store.set params.select { |k,v| k.in? %w(type view interval sort) }

    @funs = @funs.page params[:page]

    render 'index.js.erb' if request.xhr?
  end

  def autocomplete_tags
    render json: Fun.find_tags_by_name(params[:tag]).collect { |tag| tag.name.to_s } unless params[:tag].nil?
  end

  def feed
    @funs = current_user.feed.includes(:user, :content, :reposts).filter_by_type(type).sorting('created_at', interval: interval, sandbox: true).page params[:page]
    render 'index'
  end

  # GET /funs/1
  def show
    @funs = @fun.get_month_trends(current_user, cookies_store[:type]).includes(:user, :content).limit 9
    respond_to :html, :js
  end

  # GET /funs/new
  def new
    render layout: false
  end

  # GET /funs/1/edit
  def edit
  end

  # POST /funs
  def create
    @fun = current_user.funs.new(params[:fun])
    respond_to do |format|
      if @fun.save
        Stat.recount current_user, :funs
        format.html { redirect_to @fun, notice: t('funs.created') }
        format.json { render json: { success: true, path: fun_path(@fun) } }
      else
        format.html { redirect_to root_path, notice: t('funs.add_error') }
        format.json { render json: { success: false, notice: t('funs.add_error') } }
      end
    end
  end

  # PUT /funs/1
  def update
    if @fun.update_attributes(params[:fun])
      redirect_to @fun, notice: t('funs.updated')
    else
      render 'edit'
    end
  end

  # DELETE /funs/1
  def destroy
    @fun = Fun.unscoped.find params[:id]
    authorize! :destroy, @fun
    @fun.destroy
    Stat.recount current_user, :funs
    respond_to do |format|
      format.html { redirect_to funs_path, notice: t('funs.deleted') }
      format.json { render json: { success: true, notice: t('funs.deleted') } }
    end
  end

  private

  def load_users
    @users = User.joins(:stat).includes(:stat).sorting('followers', 'desc', sort_interval).limit 5
  end

  def type
    params[:type] ||= cookies_store[:type]
  end

  def interval
    params[:interval] ||= cookies_store[:interval]
  end
end
