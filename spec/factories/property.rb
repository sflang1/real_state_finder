def randomize_lat_from_center_and_distance(center, distance)
  randomized_distance = Random.rand(0.5..distance)
  distance_in_meters = randomized_distance * 1000
  angle = Random.rand(-Math::PI..Math::PI)
  distance_y = distance_in_meters * Math.sin(angle)

  # a second of latitude is approximately 30 meters.
  distance_seconds_latitude = distance_y / 30.7848
  distance_decimal_latitude = distance_seconds_latitude / 3600
  center.first + distance_decimal_latitude
end

def randomize_lng_from_center_and_distance(center, distance)
  randomized_distance = Random.rand(0.5..distance)
  distance_in_meters = randomized_distance * 1000
  angle = Random.rand(-Math::PI..Math::PI)
  distance_x = distance_in_meters * Math.cos(angle)

  # a second of latitude is approximately 30 meters.
  distance_seconds_longitude = distance_x / 30.7848
  distance_decimal_longitude = distance_seconds_longitude / 3600
  center.second + distance_decimal_longitude
end

FactoryBot.define do
  factory :property do
    transient do
      center                  { [0, 0] }
      distance_to_center      { 4 }
    end
    offer_type                { 'sell' }
    property_type             { 'apartment' }
    zip_code                  { Faker::Address.zip_code }
    street                    { Faker::Address.street_name }
    house_number              { "#{Faker::Number.within(range: 1..130)}" }
    construction_year         { Faker::Number.within(range: 1850..Time.now.year) }
    number_of_rooms           { Faker::Number.within(range: 1..6) }
    currency                  { 'eur' }
    price                     { Faker::Number.within(range: 1e6..1e8) }

    trait :in_berlin do
      # center is Brandeburger Tor.
      center                    { [52.51628808111019, 13.377883625254055] }
      city                      { 'Berlin' }
      lat                       { randomize_lat_from_center_and_distance(center, distance_to_center) }
      lng                       { randomize_lng_from_center_and_distance(center, distance_to_center) }
    end

    trait :in_munich do
      # center is Frauenkirche.
      center                    { [48.138847209368876, 11.573591456157596] }
      city                      { 'Munich' }
      lat                       { randomize_lat_from_center_and_distance(center, distance_to_center) }
      lng                       { randomize_lng_from_center_and_distance(center, distance_to_center) }
    end
  end
end