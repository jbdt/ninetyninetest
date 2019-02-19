class CreateHourSharePrices < ActiveRecord::Migration[5.2]
  def change
    create_table :hour_share_prices do |t|
      t.integer :company_id, null: false
      t.float :share_price, null: false
      t.datetime :created_at, null: false
    end
  end
end
