class Property < ApplicationRecord
  scope :within_range, lambda { |latitude, longitude, range|
    range_in_meters = range * 1000
    subquery = Property.select("earth_distance(ll_to_earth(lat, lng), ll_to_earth(#{latitude}, #{longitude})) as distance, id").to_sql
    Property.joins("INNER JOIN (#{subquery}) as sq1 on sq1.id = properties.id")
      .where('sq1.distance <= ?', range_in_meters)
  }
end