require "countries"

class PopulateCountriesAndStates < ActiveRecord::Migration
  def up
    Piggybak::Country.class_eval do
      self.table_name = 'countries'
    end
    Piggybak::State.class_eval do
      self.table_name = 'states'
    end

    ISO3166::Country.all.each do |country_array|
      name = country_array.name
      abbr = country_array.alpha2

      country = Piggybak::Country.create :name => name, :abbr => abbr

      iso3166_country = ISO3166::Country.new(abbr)
      iso3166_country.states.each do |key, value|
        name = value['name']
        abbr = key
        Piggybak::State.create! :name => name, :abbr => abbr, :country => country
      end
    end
  end

  def down
    # nothing here
  end
end
