class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :title, :null => false
      t.string :slug, :null => false
      t.text :description
      t.references :user, :null => false

      t.boolean :is_featured, :null => false, :default => false

      t.timestamps
    end
  end
end
