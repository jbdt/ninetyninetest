# == Schema Information
#
# Table name: actual_share_prices
#
#  id          :bigint(8)        not null, primary key
#  company_id  :integer          not null
#  share_price :float(24)        not null
#  created_at  :datetime         not null
#

class ActualSharePrice < ApplicationRecord
  belongs_to :company
  before_create :turn_hour

  def turn_hour
    if (last = ActualSharePrice.where(company: self.company).last)
      if (self.created_at.to_date != last.created_at.to_date) or (self.created_at.hour != last.created_at.hour)
        while (actual_share_price = ActualSharePrice.where(company: self.company).first)
          to_merge_in_hours = ActualSharePrice.where(company: self.company).select{|asp| asp.created_at.to_date == actual_share_price.created_at.to_date and asp.created_at.hour == actual_share_price.created_at.hour}
          hour_share_price = to_merge_in_hours.map(&:share_price).inject{ |sum, el| sum + el }.to_f / to_merge_in_hours.size
          HourSharePrice.create(company: self.company, share_price: hour_share_price)
          to_merge_in_hours.each(&:delete)
        end
      end
    end
  end
end
