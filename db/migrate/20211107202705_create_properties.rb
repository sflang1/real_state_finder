class CreateProperties < ActiveRecord::Migration[6.1]
  def change
    create_table :properties, if_not_exists: true do |t|
      t.string                :offer_type
      t.string                :property_type
      t.string                :zip_code
      t.string                :city
      t.string                :street
      t.string                :house_number
      t.decimal               :lat, precision: 10, scale: 6
      t.decimal               :lng, precision: 10, scale: 6
      t.integer               :construction_year
      t.integer               :number_of_rooms
      t.string                :currency
      t.integer               :price

      t.timestamps
    end
  end
end
