# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'json'

puts "Seeding Data ..."

# Helper functions
def open_asset(file_name)
  File.open(Rails.root.join('db', 'seed_assets', file_name))
end

json = ActiveSupport::JSON.decode(File.read('db/canada_data_neighbourhood.json'))

# Only run on development (local) instances not on production, etc.
unless Rails.env.development?
  puts "Development seeds only (for now)!"
  exit 0
end

# Let's do this ...

## USERS

puts "Finding or Creating User and Special Achievement ..."

testuser1 = User.create! email: 'jon@email.com', username: 'jon', password: 'password'
testuser2 = User.create! email: 'romain@email.com', username: 'romain', password: 'password'
testuser3 = User.create! email: 'xiao@email.com', username: 'xiao', password: 'password'

sights_and_landmarks = CategoryAchievement.create! name: 'All Sights & Landmarks'
museums = CategoryAchievement.create! name: 'All Museums'
zoos_and_aquariums = CategoryAchievement.create! name: 'All Zoos & Aquariums'
water_and_amusement_parks = CategoryAchievement.create! name: 'All Water & Amusement Parks'
nature_and_parks = CategoryAchievement.create! name: 'All Nature & Parks'


## ACHIEVEMENTS

puts "creating Achievements ..."

north_america = Continent.find_or_create_by! name:'North America'
canada = north_america.countries.find_or_create_by! name: 'Canada'


json["filter_array"].each do |item|
  puts item["name"]
  region = canada.regions.find_or_create_by! name: item["region"]
  city = region.cities.find_or_create_by! name: item["city"]
  neighbourhood = city.neighbourhoods.find_or_create_by! name: item["neighbourhood"]
  district = neighbourhood.districts.find_or_create_by! name: item["neighbourhood"]
  if item["type"] == "Sights & Landmarks"
    location = district.locations.find_or_create_by! ({
      name: item["name"],
      latitude: item["latitude"].to_f,
      longitude: item["longitude"].to_f,
      category: item["type"],
      category_achievement: sights_and_landmarks
    })
  elsif item["type"] == "Museums"
    location = district.locations.find_or_create_by! ({
      name: item["name"],
      latitude: item["latitude"].to_f,
      longitude: item["longitude"].to_f,
      category: item["type"],
      category_achievement: museums
    })
  elsif item["type"] == "Zoos & Aquariums"
    location = district.locations.find_or_create_by! ({
      name: item["name"],
      latitude: item["latitude"].to_f,
      longitude: item["longitude"].to_f,
      category: item["type"],
      category_achievement: zoos_and_aquariums
    })
  elsif item["type"] == "Nature & Parks"
    location = district.locations.find_or_create_by! ({
      name: item["name"],
      latitude: item["latitude"].to_f,
      longitude: item["longitude"].to_f,
      category: item["type"],
      category_achievement: nature_and_parks
    })
  elsif item["type"] == "Water & Amusement Parks"
    location = district.locations.find_or_create_by! ({
      name: item["name"],
      latitude: item["latitude"].to_f,
      longitude: item["longitude"].to_f,
      category: item["type"],
      category_achievement: water_and_amusement_parks
    })
  end
end

canada.reload

canada.regions.each do |region|
  region.cities.each do |city|
      city_location_count = 0
      city.neighbourhoods.each do |neighbourhood|
        neighbourhood.districts.each do |district|
        city_location_count+=district.locations.length
        end
      end
    if city_location_count < 20
      city.neighbourhoods.each do |neighbourhood|
        neighbourhood.districts.each do |district|
          district.locations.each do |location|
            location.destroy
          end
          district.destroy
        end
        neighbourhood.destroy
      end
      city.destroy
    end
  end
end

canada.reload

canada.regions.each do |region|
  region.cities.each do |city|
    city.neighbourhoods.each do |neighbourhood|
      neighbourhood.districts.each do |district|
        district.greatest_lat = district.locations.maximum('latitude')
        district.least_lat = district.locations.minimum('latitude')
        district.greatest_lng = district.locations.maximum('longitude')
        district.least_lng = district.locations.minimum('longitude')
        district.save
      end
    end
  end
end

canada.reload

canada.regions.each do |region|
  region.cities.each do |city|
    city.neighbourhoods.each do |neighbourhood|
      neighbourhood.greatest_lat = neighbourhood.districts.maximum('greatest_lat')
      neighbourhood.least_lat = neighbourhood.districts.minimum('least_lat')
      neighbourhood.greatest_lng = neighbourhood.districts.maximum('greatest_lng')
      neighbourhood.least_lng = neighbourhood.districts.minimum('least_lng')
      neighbourhood.save
    end
  end
end

canada.reload

canada.regions.each do |region|
  region.cities.each do |city|
    city.greatest_lat = city.neighbourhoods.maximum('greatest_lat')
    city.least_lat = city.neighbourhoods.minimum('least_lat')
    city.greatest_lng = city.neighbourhoods.maximum('greatest_lng')
    city.least_lng = city.neighbourhoods.minimum('least_lng')
    city.save
  end
end

canada.reload

canada.regions.each do |region|
  region.greatest_lat = region.cities.maximum('greatest_lat')
  region.least_lat = region.cities.minimum('least_lat')
  region.greatest_lng = region.cities.maximum('greatest_lng')
  region.least_lng = region.cities.minimum('least_lng')
  region.save
end

canada.reload

canada.greatest_lat = canada.regions.maximum('greatest_lat')
canada.least_lat = canada.regions.minimum('least_lat')
canada.greatest_lng = canada.regions.maximum('greatest_lng')
canada.least_lng = canada.regions.minimum('least_lng')
canada.save

puts "DONE!"