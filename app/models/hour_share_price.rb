# == Schema Information
#
# Table name: hour_share_prices
#
#  id          :bigint(8)        not null, primary key
#  company_id  :integer          not null
#  share_price :float(24)        not null
#  created_at  :datetime         not null
#

class HourSharePrice < ApplicationRecord
  belongs_to :company

end
