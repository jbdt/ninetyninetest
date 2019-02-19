SINCE_DEFAULT = Settings.time_series[:since_default]
TILL_DEFAULT = Settings.time_series[:till_default]

class Api::V1::TimeSeriesController < ApplicationController
  skip_before_action :authenticate, only: [:index, :show]

  def index
    interval,since,till = parse_params(params)
    render json: Company.json_companies_time_series(interval, since, till)
  end

  def show
    if (company = Company.find_by(id: params[:id]))
      interval,since,till = parse_params(params)
      render json: company.json_company_time_series(interval, since, till)
    else
      render json: {}
    end
  end

  private
  def parse_params(params)
    interval = %w(hourly daily weekly).index(params[:interval]) ? params[:interval] : 'hourly'
    since = params[:since].to_datetime rescue nil || Time.now.to_datetime - SINCE_DEFAULT
    till = params[:till].to_datetime rescue nil || Time.now.to_datetime - TILL_DEFAULT
    [interval,since,till]
  end

end