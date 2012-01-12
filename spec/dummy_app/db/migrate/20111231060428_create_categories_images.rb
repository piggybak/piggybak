class CreateCategoriesImages < ActiveRecord::Migration
  def change
    create_table :categories_images, :id => false do |t|
      t.references :category
      t.references :image
    end
  end
end
