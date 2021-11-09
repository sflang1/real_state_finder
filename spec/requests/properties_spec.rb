require 'rails_helper'

RSpec.describe 'Property search', type: :request do
  context 'invalid input' do
    describe 'proper rendering of response if inputs are invalid' do
      it 'should render bad_request if latitude is null' do
        get '/api/properties/search', params: { lng: -20, property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body['message']).to include  'Lat is a required field'
      end

      it 'should render bad_request if longitude is null' do
        get '/api/properties/search', params: { lat: -20, property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body['message']).to include  'Lng is a required field'
      end

      it 'should render bad_request if property_type is null' do
        get '/api/properties/search', params: { lat: -20, lng: -20, marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body['message']).to include  'Property type is a required field'
      end

      it 'should render bad_request if marketing_type is null' do
        get '/api/properties/search', params: { lat: -20, lng: -20, property_type: 'apartment' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body['message']).to include  'Marketing type is a required field'
      end

      it 'should render bad_request if latitude is not a numeric value' do
        get '/api/properties/search', params: { lat: 'testing', lng: -20, property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body['message']).to include  'Lat should be a numeric value'
      end

      it 'should render bad_request if longitude is not a numeric value' do
        get '/api/properties/search', params: { lng: 'testing', lat: -20, property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body['message']).to include  'Lng should be a numeric value'
      end

      it 'should render bad_request if property type is not apartment or single_family_house' do
        get '/api/properties/search', params: { lng: -20, lat: -20, property_type: 'testing', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body['message']).to include  'Property type should be apartment or single_family_house'
      end

      it 'should render bad_request if marketing type is not rent or sell' do
        get '/api/properties/search', params: { lng: -20, lat: -20, property_type: 'apartment', marketing_type: 'testing' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body['message']).to include  'Marketing type should be rent or sell'
      end
    end

    describe 'proper rendering of response if no properties are found' do
      before do
        FactoryBot.create_list(:property, 4, :in_berlin, distance_to_center: 4)
        FactoryBot.create_list(:property, 2, :in_berlin, distance_to_center: 4, property_type: 'single_family_house')
        FactoryBot.create_list(:property, 2, :in_berlin, distance_to_center: 4, offer_type: 'rent')
        FactoryBot.create_list(:property, 4, :in_berlin, distance_to_center: 4, property_type: 'single_family_house', offer_type: 'rent')
      end

      it 'should return not found response if no properties were found for the given latitude/longitude' do
        # this property would be located in the Frauenkirche, Munich. No Berlin properties should be shown.
        get '/api/properties/search', params: { lat: 48.138847209368876, lng: 11.573591456157596 , property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       404
        expect(body['message']).to include  'No properties found for your search'
      end
    end
  end

  context 'valid input' do
    describe 'proper rendering of response if input is valid' do
      before do
        @property = FactoryBot.create(:property, :in_berlin, distance_to_center: 4)
      end

      it 'should render properly a property' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq                           200
        expect(body['data']['data'].count).to eq                1

        item = body['data']['data'].first
        expect(item.count).to eq                                8    # the item should have 8 keys
        expect(item['id']).to eq                                @property.id
        expect(item['house_number']).to eq                      @property.house_number
        expect(item['street']).to eq                            @property.street
        expect(item['city']).to eq                              @property.city
        expect(item['zip_code']).to eq                          @property.zip_code
        expect(item['lat']).to eq                               @property.lat.to_s
        expect(item['lng']).to eq                               @property.lng.to_s
        expect(item['price']).to eq                             @property.price.to_s
      end
    end

    describe 'renders the proper records according to the input' do
      before do
        @berlin_sell_apartments = FactoryBot.create_list(:property, 4, :in_berlin, distance_to_center: 4)
        @berlin_sell_single_family_houses = FactoryBot.create_list(:property, 2, :in_berlin, distance_to_center: 4, property_type: 'single_family_house')
        @berlin_rent_apartments = FactoryBot.create_list(:property, 2, :in_berlin, distance_to_center: 4, offer_type: 'rent')
        @berlin_rent_single_family_houses = FactoryBot.create_list(:property, 4, :in_berlin, distance_to_center: 4, property_type: 'single_family_house', offer_type: 'rent')

        # create some properties in munich for testing that the latitude longitude works
        FactoryBot.create_list(:property, 4, :in_munich, distance_to_center: 4)
        FactoryBot.create_list(:property, 2, :in_munich, distance_to_center: 4, property_type: 'single_family_house')
        FactoryBot.create_list(:property, 2, :in_munich, distance_to_center: 4, offer_type: 'rent')
        FactoryBot.create_list(:property, 4, :in_munich, distance_to_center: 4, property_type: 'single_family_house', offer_type: 'rent')
      end

      it 'should show just the corresponding records when looking for sell and apartment' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        data = body['data']['data']
        expect(response.status).to eq                           200
        expect(data.count).to eq                                4
        expect(@berlin_sell_apartments.pluck(:id)).to eq        data.map { |el| el['id'] }
      end

      it 'should show just the corresponding records when looking for sell and single family houses' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'single_family_house', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        data = body['data']['data']
        expect(response.status).to eq                                     200
        expect(data.count).to eq                                          2
        expect(@berlin_sell_single_family_houses.pluck(:id)).to eq        data.map { |el| el['id'] }
      end

      it 'should show just the corresponding records when looking for rent and apartment' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'rent' }

        body = JSON.parse(response.body)
        data = body['data']['data']
        expect(response.status).to eq                           200
        expect(data.count).to eq                                2
        expect(@berlin_rent_apartments.pluck(:id)).to eq        data.map { |el| el['id'] }
      end

      it 'should show just the corresponding records when looking for rent and single family houses' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'single_family_house', marketing_type: 'rent' }

        body = JSON.parse(response.body)
        data = body['data']['data']
        expect(response.status).to eq                                     200
        expect(data.count).to eq                                          4
        expect(@berlin_rent_single_family_houses.pluck(:id)).to eq        data.map { |el| el['id'] }
      end
    end

    describe 'pagination works properly' do
      before do
        FactoryBot.create_list(:property, 50, :in_berlin, distance_to_center: 4)
      end

      it 'should render by default page 1 composed by 20 items' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        pagination = body['data']['pagination']
        data = body['data']['data']

        expect(response.status).to eq                 200
        expect(body['success']).to eq                 true
        expect(data.count).to eq                      20
        expect(pagination['vars']['page']).to eq      1
        expect(pagination['vars']['items']).to eq     20
      end

      it 'should render the proper number of results when per_page param is sent' do
        per_page = 10
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'sell', per_page: per_page }

        body = JSON.parse(response.body)
        pagination = body['data']['pagination']
        data = body['data']['data']

        expect(response.status).to eq                       200
        expect(body['success']).to eq                       true
        expect(data.count).to eq                            per_page
        expect(pagination['vars']['page']).to eq            1
        expect(pagination['vars']['items'].to_i).to eq      per_page

        per_page = 30
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'sell', per_page: per_page }

        body = JSON.parse(response.body)
        pagination = body['data']['pagination']
        data = body['data']['data']

        expect(response.status).to eq                       200
        expect(body['success']).to eq                       true
        expect(data.count).to eq                            per_page
        expect(pagination['vars']['page']).to eq            1
        expect(pagination['vars']['items'].to_i).to eq      per_page
      end

      it 'should render the proper page when page param is sent' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'sell'}

        body = JSON.parse(response.body)
        pagination = body['data']['pagination']
        data = body['data']['data']
        first_page_ids = data.map{|el| el['id']}

        expect(response.status).to eq                       200
        expect(body['success']).to eq                       true
        expect(data.count).to eq                            20
        expect(pagination['vars']['page']).to eq            1
        expect(pagination['vars']['items'].to_i).to eq      20

        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'sell', page: 2 }

        body = JSON.parse(response.body)
        pagination = body['data']['pagination']
        data = body['data']['data']

        second_page_ids = data.map {|el| el['id']}

        expect(response.status).to eq                       200
        expect(body['success']).to eq                       true
        expect(data.count).to eq                            20
        expect(pagination['vars']['page'].to_i).to eq       2
        expect(pagination['vars']['items'].to_i).to eq      20

        # The intersection of records in both pages should be empty, as no record should be repeated in the next page
        expect(first_page_ids & second_page_ids).to eq      []
      end
    end
  end
end