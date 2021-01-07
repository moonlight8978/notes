class City < ApplicationRecord
  has_many :satellites
  has_one :population
end
