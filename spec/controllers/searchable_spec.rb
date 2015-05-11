module Searchengine
  class DummiesController < ActionController::Base
    #include Searchengine::Concerns::Models::Searchable
    include Searchengine::Concerns::Controllers::Searchable
  end

  Engine.routes.draw do
    get '/search', to: 'dummies#search'
  end
end

describe Searchengine::DummiesController, type: :controller do
  routes { Searchengine::Engine.routes }

  describe 'supporting search' do
    it 'responds to the #search action' do
      #Searchengine::Engine.routes.named_routes.each { |r, s|  
      #  p s # "r=#{r} s=#{s}" 
      #}
      get :search
      expect(response.status).to eq(200)
    end
  end
end
