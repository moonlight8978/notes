class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email
      t.string :gender
      t.string :name

      t.timestamps

      t.index [:username, :email, :gender]
      t.index :name
    end
  end
end
