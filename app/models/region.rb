class Region < ApplicationRecord
  belongs_to :country
  has_many :cities

    def as_json(options={})
    {
      id: id,
      name: name,
      country_id: country_id,
      created_at: created_at,
      updated_at: updated_at,
      cities_ids: cities.to_a.map{ |city| city.region_id},
      least_lat: least_lat,
      greatest_lat: greatest_lat,
      least_lng: least_lng,
      greatest_lng: greatest_lng
    }
  end
end
