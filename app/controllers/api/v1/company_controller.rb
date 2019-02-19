class Api::V1::CompanyController < ApplicationController
  skip_before_action :authenticate, only: [:show, :index]

  def index
    render json: Company.json_companies
  end

  def show
    render json: Company.json_company(params[:id].to_i)
  end
end