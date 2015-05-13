class CreateCharacters < ActiveRecord::Migration
  def change
    create_table :characters do |t|
      t.string :name
      t.string :email
      t.string :description

      t.timestamps
    end
  end
end
