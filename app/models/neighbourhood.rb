class Neighbourhood < ApplicationRecord
  belongs_to :city
  has_many :districts
end
