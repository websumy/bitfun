class FunsController < ApplicationController
  load_and_authorize_resource

  # GET /funs
  def index
    if params[:tag]
      tag = Tag.find_by_name(params[:tag])
      if tag.present?
        @funs = tag.funs.includes(:user).paginate(page: params[:page], per_page: 5)
      else
        redirect_to funs_path, notice: "No results for tag \"#{params[:tag]}\""
      end
    else
      if current_user
        @funs = current_user.feed.includes(:user).paginate(page: params[:page], per_page: 5)
      else
        @funs = Fun.includes(:user).paginate(page: params[:page], per_page: 5)
      end
    end
  end

  # GET /funs/1
  def show
    @fun = Fun.find(params[:id])
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
end
