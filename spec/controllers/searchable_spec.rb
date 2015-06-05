require 'spec_helper'

module Searchengine
  class CitiesController < ActionController::Base
  end

  class CountriesController < ActionController::Base
  end

  class City < ActiveRecord::Base
    include Searchengine::Concerns::Models::Searchable
  end

  class Country < ActiveRecord::Base
    include Searchengine::Concerns::Models::Searchable
  end

  Engine.routes.draw do
    get '/search', to: 'cities#query'

    resources :countries do
      collection do
        searchable
      end
    end
  end
end

describe Searchengine::CitiesController, type: :controller do
  before(:each) do
    Searchengine::CitiesController.class_eval do
      include Searchengine::Concerns::Controllers::Searchable
    end
    allow(Searchengine::City).to receive(:set) { |name, val|
      stub_const "Searchengine::Indices::#{name}", val
    }
  end

  routes { Searchengine::Engine.routes }

  describe 'supporting search' do
    before(:each) do
      Searchengine::City.searchable_as('Dummy') do |index|
        index.define_type Searchengine::City do |type|
          type.field :email, :string
        end
      end
      Searchengine::CitiesController.searches(Searchengine::City)
    end

    it 'responds to the #search action' do
      get :query
      expect(response.status).to eq(200)
    end
    
    it 'calls the #process_query with the appropriate query content' do
      expect(controller.class).to receive(:process_query).with(hash_including(q: 'lisa'))
      get :query, q: 'lisa'
    end
  end

  context 'pagination' do
    let(:details) { }
    before {
      Searchengine::City.searchable_as('Dummy') do |index|
        index.define_type Searchengine::City do |type|
          type.field :email, :string
        end
      end
      Searchengine::CitiesController.searches(Searchengine::City)
    }
    subject { controller.class }

    it 'set the starting marker' do
      skip
      expect(subject.find('New', from: 7)).to be_nil
    end

    it 'sets the count of items to return' do
      skip
      expect(subject.find('New', size: 3)).to be_nil
    end

    it 'returns the standard count of items' do
      skip
      expect(subject.find('New')).to be_nil
    end
  end

  context 'query constructor' do
    before { skip }

    let(:details) {
      { 
        filter: { range: { age: { gte: 100 } } },
        order: { email: :desc },
        offset: 12,
        limit: 10
      }
    }
    subject { controller.class }

    it 'sets the ordering' do
      is_expected.to receive(:query_ordered).with(anything, details[:order])
      expect(subject.find('New', details)).to_not be_nil
    end

    it 'sets the filtering' do
      is_expected.to receive(:query_filtered).with(anything, details[:filter])
      expect(subject.find('New', details)).to_not be_nil
    end

    it 'sets the offset' do
      is_expected.to receive(:query_offsetted).with(anything, details[:offset])
      expect(subject.find('New', details)).to_not be_nil
    end

    it 'sets the limit' do
      is_expected.to receive(:query_limited).with(anything, details[:limit])
      expect(subject.find('New', details)).to_not be_nil
    end
  end
end
