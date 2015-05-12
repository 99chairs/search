module Searchengine
  class ButterfliesController < ActionController::Base
  end
end

describe 'Routes', type: :routing do
  routes { Searchengine::Engine.routes }

  it 'directs a searchability route to the specified controller' do
    Searchengine::Engine.routes.draw do
      searchability_for :butterflies, controller: 'butterflies'
    end
    expect(get: '/butterflies/query').to route_to(
      controller: 'searchengine/butterflies',
      action: 'query'
    )
  end

  it 'directs a searchability route to an implied controller' do
    Searchengine::Engine.routes.draw do
      searchability_for :butterflies
    end
    expect(get: '/butterflies/query').to route_to(
      controller: 'searchengine/butterflies',
      action: 'query'
    )
  end

  it 'infers the controller from the resource' do
    Searchengine::Engine.routes.draw do
      resources :butterflies do
        collection do
          searchable
        end
      end
    end
    expect(get: '/butterflies/query').to route_to(
      controller: 'searchengine/butterflies',
      action: 'query'
    )
  end
end
