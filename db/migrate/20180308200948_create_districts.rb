class CreateDistricts < ActiveRecord::Migration[5.1]
  def change
    create_table :districts do |t|
      t.string :name
      t.references :neighbourhood, foreign_key: true

      t.timestamps
    end
  end
end
