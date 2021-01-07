class CreateWishlists < ActiveRecord::Migration[5.2]
  def change
    create_table :wishlists do |t|
      t.belongs_to :user

      t.string :item

      t.timestamps
    end
  end
end
