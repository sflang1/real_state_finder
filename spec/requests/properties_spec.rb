require 'rails_helper'

RSpec.describe 'Property search', type: :request do
  context 'invalid input' do
    describe 'proper rendering of response if inputs are invalid' do
      it 'should render bad_request if latitude is null' do
        get '/api/properties/search', params: { lng: -20, property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body.message).to eq          'Latitude is a required field'
      end

      it 'should render bad_request if longitude is null' do
        get '/api/properties/search', params: { lat: -20, property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body.message).to eq          'Longitude is a required field'
      end

      it 'should render bad_request if property_type is null' do
        get '/api/properties/search', params: { lat: -20, lng: -20, marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body.message).to eq          'Property type is a required field'
      end

      it 'should render bad_request if marketing_type is null' do
        get '/api/properties/search', params: { lat: -20, lng: -20, property_type: 'apartment' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body.message).to eq          'Marketing type is a required field'
      end

      it 'should render bad_request if latitude is not a numeric value' do
        get '/api/properties/search', params: { lat: 'testing', lng: -20, property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body.message).to eq          'Latitude is not a numeric value'
      end

      it 'should render bad_request if longitude is not a numeric value' do
        get '/api/properties/search', params: { lng: 'testing', lat: -20, property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body.message).to eq          'Longitude is not a numeric value'
      end

      it 'should render bad_request if property type is not apartment or single_family_house' do
        get '/api/properties/search', params: { lng: -20, lat: -20, property_type: 'testing', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body.message).to eq          'Property type should be apartment or single_family_house'
      end

      it 'should render bad_request if marketing type is not rent or sell' do
        get '/api/properties/search', params: { lng: -20, lat: -20, property_type: 'apartment', marketing_type: 'testing' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       400
        expect(body.message).to eq          'Marketing type should be rent or sell'
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
        get '/api/properties/search', params: { lat: 48.138847209368876, lng: 11.573591456157596 , property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq       404
        expect(body.message).to eq          'No properties found for your search'
      end
    end
  end

  context 'valid input' do
    describe 'proper rendering of response if input is valid' do
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

      it 'should show the proper results when looking for sell and apartment' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq                           200
        expect(response.data.count).to eq                       4
        expect(@berlin_sell_apartments.pluck(:id)).to eq        response.data.map { |el| el[:id] }
      end

      it 'should show the proper results when looking for sell and single family houses' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'single_family_house', marketing_type: 'sell' }

        body = JSON.parse(response.body)
        expect(response.status).to eq                                     200
        expect(response.data.count).to eq                                 2
        expect(@berlin_sell_single_family_houses.pluck(:id)).to eq        response.data.map { |el| el[:id] }
      end

      it 'should show the proper results when looking for rent and apartment' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'apartment', marketing_type: 'rent' }

        body = JSON.parse(response.body)
        expect(response.status).to eq                           200
        expect(response.data.count).to eq                       2
        expect(@berlin_rent_apartments.pluck(:id)).to eq        response.data.map { |el| el[:id] }
      end

      it 'should show the proper results when looking for rent and single family houses' do
        get '/api/properties/search', params: { lat: 52.51628808111019, lng: 13.377883625254055 , property_type: 'single_family_house', marketing_type: 'rent' }

        body = JSON.parse(response.body)
        expect(response.status).to eq                                     200
        expect(response.data.count).to eq                                 4
        expect(@berlin_rent_single_family_houses.pluck(:id)).to eq        response.data.map { |el| el[:id] }
      end
    end
  end
end