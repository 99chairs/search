class Show < ActiveRecord::Base
  include Searchengine::Concerns::Models::Searchable
  searchable_as('Fehrsehen') do |index|
    index.define_type Show do |type|
      type.field :name, type: 'string'
      type.field :producer, type: 'string'
    end
  end
  updatable_as('fehrsehen', 'show')
  #update_index 'fehrsehen#show', :self
end
