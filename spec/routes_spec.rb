module Searchengine
  class ButterfliesController < ActionController::Base
  end
end

describe 'Routes', type: :routing do
  routes { Searchengine::Engine.routes }

  it 'directs a searchability route to the search controller' do
    Searchengine::Engine.routes.draw do
      searchability_for :butterflies, controller: 'butterflies'
    end
    expect(:get => '/search/butterflies').to route_to(
      controller: 'searchengine/butterflies',
      action: 'query'
    )
  end
end
