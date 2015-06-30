class AddCategoryToCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :category, :string
  end
end
