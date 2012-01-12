class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :title, :null => false
      t.string :slug, :null => false
      t.text :description
      t.references :user, :null => false

      t.string :main_file_name
      t.string :main_content_type
      t.string :main_file_size
      t.datetime :main_updated_at

      t.boolean :is_featured, :null => false, :default => false

      t.timestamps
    end
  end
end
