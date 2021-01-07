class AddAgeToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :age, :integer

    add_index :users, [:age, :gender]
  end
end
