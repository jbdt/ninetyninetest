# == Schema Information
#
# Table name: companies
#
#  id          :bigint(8)        not null, primary key
#  api_id      :integer          not null
#  name        :string(255)      default("")
#  ric         :string(255)      default("")
#  description :text(65535)
#  country     :string(255)      default("")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

CON_ID = Settings.api_connection[:id]
CON_NAME = Settings.api_connection[:name]
CON_RIC = Settings.api_connection[:ric]
CON_DESCRIPTION = Settings.api_connection[:description]
CON_COUNTRY = Settings.api_connection[:country]
CON_SHARE_PRICE = Settings.api_connection[:share_price]

RES_ID = Settings.api_response[:id]
RES_NAME = Settings.api_response[:name]
RES_RIC = Settings.api_response[:ric]
RES_DESCRIPTION = Settings.api_response[:description]
RES_COUNTRY = Settings.api_response[:country]
RES_SHARE_PRICE = Settings.api_response[:share_price]

class Company < ApplicationRecord
  include ApiConnection
  has_many :actual_share_prices
  has_many :hour_share_prices

  def self.update_news
    if (json_companies = ApiConnection.call_api)
      ids = check_news json_companies
      ids.each do |id|
        if (company = ApiConnection.call_api id)
          fill_company company
        end
      end
    end
    json_companies
  end

  def self.update_actual_share_price(json_companies)
    Company.all.each do |company|
      json_company = json_companies.select{|json_company| json_company[CON_ID] == company.api_id}.first
      ActualSharePrice.create(company: company, share_price: json_company[CON_SHARE_PRICE].to_f)
    end
  end

  def self.json_companies
    response = []
    Company.all.map do |company|
      response << company.json_companies_hash
    end
    response
  end

  def self.json_company(id)
    return {} unless (company = Company.find_by(id: id))
    company.json_company_hash
  end

  def json_company_time_series(interval, since, till)
    return {} unless (company = Company.find_by(id: id))
    response = company.json_company_hash
    hour_share_prices = company.hour_share_prices.where(created_at: since..till).order(:created_at)
    response[:time_series] = hour_share_prices.empty? ? {} : apply_interval_time_series(interval, hour_share_prices)
    response
  end

  def self.json_companies_time_series(interval, since, till)
    Company.all.map{|company| company.json_company_time_series(interval, since, till)}
  end

  def json_companies_hash
    {
        "#{RES_ID}": self.id,
        "#{RES_NAME}": self.name,
        "#{RES_RIC}": self.ric,
        "#{RES_SHARE_PRICE}": self.actual_share_prices.last.try(:share_price) || 0
    }
  end

  def json_company_hash
    self.json_companies_hash.merge(
        {
            "#{RES_DESCRIPTION}": self.description,
            "#{RES_COUNTRY}": self.country
        }
    )
  end

  private
  def self.check_news(json_companies)
    api_ids = Company.all.map(&:api_id)
    json_ids = json_companies.map{|json_company| json_company[CON_ID]}
    json_ids - api_ids
  end

  def self.fill_company(company)
    Company.create(
        api_id: company[CON_ID],
        name: company[CON_NAME],
        ric: company[CON_RIC],
        description: company[CON_DESCRIPTION],
        country: company[CON_COUNTRY])
  end

  def apply_interval_time_series(interval, hour_share_prices)
    case interval
    when 'hourly'
      return hour_share_prices.map{|hsp| {hsp.created_at.beginning_of_hour => hsp.share_price.round(2)}}.reduce(:merge)
    when 'daily'
      result = {}
      hour_share_prices.each{|hsp| (result[hsp.created_at.to_date] ||= [] ) << hsp.share_price}
    when 'weekly'
      result = {}
      hour_share_prices.each{|hsp| (result["#{hsp.created_at.strftime("%U").to_i}/#{hsp.created_at.year}"] ||= []) << hsp.share_price}
    end
    result.map{|k,v| {k => (v.inject(&:+).to_f / v.size).round(2)}}.reduce(:merge)
  end
end