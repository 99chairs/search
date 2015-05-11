module Searchengine
  class DummiesController < ActionController::Base
  end

  Engine.routes.draw do
    get '/search', to: 'dummies#search'
  end
end

describe Searchengine::DummiesController, type: :controller do
  before(:each) do
    Searchengine::DummiesController.class_eval do
      include Searchengine::Concerns::Controllers::Searchable
    end
  end

  routes { Searchengine::Engine.routes }

  describe 'supporting search' do
    it 'responds to the #search action' do
      get :search
      expect(response.status).to eq(200)
    end
  end
end
