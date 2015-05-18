require 'rails_helper'

RSpec.describe ShowsController, type: :controller do
  before(:all) do
    Chewy.massacre

    puts Show.search_index
    Show.search_index.create!
    Show.create name: 'Fringe', producer: 'J.J. Abrams', piloted_at: DateTime.now
    Show.create name: 'The Wire', producer: 'David Simon', piloted_at: DateTime.now
    Show.create name: 'Game of Thrones', producer: 'Beinoff & Weiss', piloted_at: DateTime.now
    Show.create name: 'Sherlock', producer: 'Moffat & Gatiss', piloted_at: DateTime.now
    Show.create name: 'House of Cards', producer: 'Beau Willimon', piloted_at: DateTime.now
    Show.create name: 'Little House on the Prairie', producer: 'Michael Landon', piloted_at: DateTime.now
  end

  after(:all) do
    Show.destroy_all
  end

  describe "GET /index" do
    before { get :index }

    it 'returns a list of the shows' do
      expect(json_response.length).to eq(Show.count)
    end
  end

  describe "GET /query" do
    before { 
      Show.search_type.import! refresh: :true
      20.times { Show.search_type.query(query_string: { query: 'hous*' }).total_count }
      get :query, { q: 'hous*' } 
    }

    it 'contains the matching items' do
      puts request.url
      expect(json_response[:responseData][:count]).to eq(2)
    end
  end
end
