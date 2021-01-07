class CreatePopulations < ActiveRecord::Migration[6.0]
  def change
    create_table :populations do |t|
      t.belongs_to :city
      t.integer :number

      t.timestamps
    end
  end
end
