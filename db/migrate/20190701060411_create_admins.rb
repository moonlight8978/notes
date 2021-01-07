class CreateAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :admins do |t|
      t.string :username
      t.string :email
      t.string :name

      t.timestamps

      t.index :username
      t.index :email
    end
  end
end
