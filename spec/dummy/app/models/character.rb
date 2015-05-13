class Character < ActiveRecord::Base
  include Searchengine::Concerns::Models::Searchable
  searchable_as('Fehrsehen') do |index|
    index.define_type Character do |type|
      type.field :name, :string
      type.field :email, :string
      type.field :description, :string
    end
  end
  updatable_as('fehrsehen', 'character')
end
