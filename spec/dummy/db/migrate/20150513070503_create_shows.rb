class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.string :name
      t.datetime :piloted_at
      t.string :producer

      t.timestamps
    end
  end
end
