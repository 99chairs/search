class Show < ActiveRecord::Base
  include Searchengine::Concerns::Models::Searchable
  extend Chewy::Type::Observe::ActiveRecordMethods

  searchable_as('test') do |index|
    index.define_type Show do |type|
      type.field :name, type: 'string'
      type.field :producer, type: 'string'
    end
  end
  updatable_as('test', 'show')
end
