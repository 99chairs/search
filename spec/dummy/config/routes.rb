Rails.application.routes.draw do

  mount Searchengine::Engine => "/search"

  resources :characters do
    collection do
      get 'facets', to: 'characters#facets'
      get 'query', to: 'characters#query'
    end
  end

  resources :shows do
    collection do
      searchable
    end
  end
end
