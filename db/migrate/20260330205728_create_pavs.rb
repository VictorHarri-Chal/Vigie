class CreatePavs < ActiveRecord::Migration[8.0]
  def change
    create_table :pavs do |t|
      t.string :pav_id
      t.string :name
      t.string :address
      t.string :city
      t.string :zip
      t.float :lat
      t.float :lng
      t.string :waste_type
      t.integer :capacity_liters

      t.timestamps
    end

    add_index :pavs, :pav_id, unique: true
    add_index :pavs, :waste_type
  end
end
