class Character < ActiveRecord::Base
  include Searchengine::Concerns::Models::Searchable
  searchable_as('test') do
    define_type Character do
      field :name, type: 'string'
      field :email, type: 'string'
      field :description, type: 'string'
      field :category, type: 'string'
      field :category_name, 
        value: ->(c) { c.category }, 
        type: 'string', 
        index: 'not_analyzed'
    end
  end

  updatable_as('test', 'character')
end
