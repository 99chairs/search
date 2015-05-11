Rails.application.routes.draw do

  mount Searchengine::Engine => "/search"
end
