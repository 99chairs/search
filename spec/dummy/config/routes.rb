Rails.application.routes.draw do

  mount Searchengine::Engine => "/search"

  resources :shows do
    collection do
      searchable
    end
  end
end
