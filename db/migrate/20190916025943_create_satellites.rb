class CreateSatellites < ActiveRecord::Migration[6.0]
  def change
    create_table :satellites do |t|
      t.belongs_to :city
      t.string :name

      t.timestamps
    end
  end
end
