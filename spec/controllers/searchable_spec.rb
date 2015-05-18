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
end
