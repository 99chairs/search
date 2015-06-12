require 'rails_helper'

RSpec.describe CharactersController, type: :controller do
  before(:all) { setup_dummy_dataset }

  after(:all) do
    Character.destroy_all
  end

  it 'has characters' do
    get :index

    Character.all.each do |character|
      expect(json_response).to include(hash_including(name: character.name))
    end
  end

  it 'builds the facets' do
    get :facets
    expect(json_response).to match(a_hash_including(
      category: including(a_hash_including(:key, :doc_count)),
    ))
  end

  it 'runs the query' do
    filtering_details = { q: '*', description: ['guy'], category: ['South Park'] }
    p CharactersSearchTypeService.new.compose_filters(filtering_details)
    get :query, filtering_details
    puts request.url
  end
end
