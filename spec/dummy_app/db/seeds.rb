# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

User.delete_all
Role.delete_all
Image.delete_all
Piggybak::Variant.delete_all

puts "Generating roles"
role_admin = Role.create :name => "admin"

user_steph = User.create! :email => 'steph@endpoint.com', :password => 'foobar', :password_confirmation => 'foobar', :display_name => "Steph Skardal"
user_steph.roles << role_admin



puts "Generating sample variants"
image_sample = Image.create! :title => "Sample Image", :slug => "sample-image", :user => user_steph
product_sample = Piggybak::Variant.create! :sku => "1", :description => "Sample Variant", :price => 19.99, :item => image_sample, :quantity => 9, :active => true
