class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.integer :api_id, null: false
      t.string  :name, :default => ''
      t.string  :ric, :default => ''
      t.text    :description
      t.string  :country, :default => ''
      t.timestamps
    end
  end
end
