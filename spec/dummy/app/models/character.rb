class Character < ActiveRecord::Base
  include Searchengine::Concerns::Models::Searchable
  searchable_as('test') do |index|
    index.settings analysis: {
      analyzer: {
        user_email: {
          tokenizer: 'uax_url_email'
        }
      }
    }

    index.define_type Character do |type|
      type.field :name, type: 'string'
      type.field :email, type: 'string' #analyzer: :user_email
      type.field :description, type: 'string'
      type.field :category, type: 'string'
      type.field :category_name, 
        value: ->(c) { c.category }, 
        type: 'string', 
        index: 'not_analyzed'
    end
  end

  updatable_as('test', 'character')
end
