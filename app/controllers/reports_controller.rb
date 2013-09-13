class ReportsController < ApplicationController
  before_filter :only_xhr_request, only: :new
  authorize_resource

  def index
    @reports = Report.includes(:user, :fun).all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reports }
    end
  end

  def new
    @report = Report.new
    @fun = Fun.find(params[:fun_id])

    render layout: false
  end

  def create
    @fun = Fun.find(params[:fun_id])
    @report = @fun.reports.new(user: current_user, abuse: params[:report][:abuse])
    if @report.save
      render json: { success: true, notice: t('funs.reports.created') }
    else
      render json: { success: false, notice: t('funs.reports.error') }
    end
  end

  def destroy
    @report = Report.find(params[:id])
    @report.destroy

    respond_to do |format|
      format.html { redirect_to reports_url }
      format.json { head :no_content }
    end
  end
end
