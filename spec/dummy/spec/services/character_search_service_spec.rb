require 'rails_helper'

RSpec.describe CharactersSearchTypeService do
  before(:all) { setup_dummy_dataset }
  after(:all) { destroy_dummy_dataset }

  let(:service) { CharactersSearchTypeService.new }

  it 'composes the query details' do
    expect(service.extract_query(from: { q: 'Simpsons' })).to match(a_hash_including(
      multi_match: anything
    ))
  end

  it 'composes the filter details' do
    expect(service.extract_filter(from: { q: 'Griffin', category: 'Family Guy'})).to match(a_hash_including(
      terms: a_hash_including(category_name: anything)
    ))
  end

  it 'extract filter details from params' do
    filter = { category: 'test', types: 'failing' }
    expect(service.extract_filter_terms(from: filter)).to match(
      { category_name: 'test' }
    )
  end

  it 'maps filter names to field names' do
    expect(service.field_mapping for_attribute: 'category').to match /category_name/
    expect(service.field_mapping for_attribute: :category).to match /category_name/
    expect(service.field_mapping for_attribute: :description).to match /description/
    expect(service.field_mapping for_attribute: 'description').to match /description/
  end

  it('finds all Simpsons') { results from: { 'q' => 'Simpson' }, contains: [
    a_hash_including('name' => 'Homer Simpson', 'category' => 'The Simpsons'),
    a_hash_including('name' => 'Homer Simpson', 'category' => 'Family Guy'),
    a_hash_including('name' => 'Bart Simpson')
  ] } 

  it('finds all guys') { results from: { 'q' => 'guy' }, count: 11 } 
  it('finds all South Park guys') { 
    results from: { 'q' => 'guy', 'category' => ['South Park'] }, count: 3 
  }

  def results(from: params, contains: [], count: false)
    search_results = service.query(from)
    expect(search_results).to include(*contains) unless contains.empty?
    expect(search_results.count).to eq(count) if count
  end
end
