require 'rails_helper'

RSpec.describe Character, type: :model do
  before(:all) do
    Character.destroy_all
    Chewy.massacre
    populate_dummy_dataset
    wait_until_index_is_populated
  end

  after(:all) do
    Character.destroy_all
  end

  it 'does something', type: 'aggs' do
    p aggregations
    fail
  end

  it 'finds Caligula by his full e-mail address', type: 'search' do
    expect(search_results_for('cali@la.it')).to include(a_hash_including('name' => 'Caligula'))
  end

  ['cali@la', 'cali', 'cali@'].each do |phrase|
    it "finds Caligula by his e-mail address token #{phrase}", type: 'search' do
      expect(search_results_for(phrase)).to include(a_hash_including('name' => 'Caligula'))
    end
  end

  ['*cali@la.it*', '*cali@la.it', 'cali@la.it*', 'cali*', '*cali*', '*i@la*', '*ali', '*ali*', '*@la', '*@la.it', '*.it', '*.it*', '*it'].each do |phrase|
    it "finds Caligula by his wildcarded e-mail address #{phrase}", type: 'search' do
      expect(search_results_for(phrase)).to include(a_hash_including('name' => 'Caligula'))
    end
  end

  def search_results_for(phrase)
    find_by_searchphrase(phrase).map(&:attributes)
  end

  def aggregations
    Character.search_type.aggregations(
      categories: {
        terms:  {
          field: 'category_name',
          execution_hint: 'global_ordinals_low_cardinality',
        }
      },
#      categories: {
#        filters: { 
#          { term: { body: 'something' } },
#        }
#        aggs: {
#          
#        }
#      }
      unique_categories_count: { cardinality: { field: 'category' } },
      categories_count: { value_count: { field: 'category' } },
      description: { terms: { field: 'description' } },
    ).aggregations
  end

  def find_by_searchphrase(phrase)
    q = { query_string: { query: "#{phrase}", analyze_wildcard: true } }
    Character.search_type.query(q)
  end

  def populate_dummy_dataset
    characters = [
      { name: 'Julius Caesar', description: 'statesman, general', email: 'julius@caesar.it' },
      { name: 'Nero', description: 'brute', email: 'nero@rome.it' },
      { name: 'Caligula', description: 'promiscuous prick', email: 'cali@la.it' },
      { name: 'Peter Griffin', description: 'the fat guy', category: 'Family Guy' },
      { name: 'Stewie Griffin', description: 'evil baby', category: 'Family Guy' },
      { name: 'Brian Griffin', description: 'talking dog', category: 'Family Guy' },
      { name: 'Mort', description: 'the jew', category: 'Family Guy' },
      { name: 'Adam West', category: 'Family Guy' },
      { name: 'Megatron Griffin', category: 'Family Guy' },
      { name: 'Montogomery Burns', description: 'evil old fart', category: 'The Simpsons' },
      { name: 'Homer Simpson', description: 'the fat guy', category: 'The Simpsons' },
      { name: 'Bart Simpson', description: 'eat my shorts', category: 'The Simpsons' },
      { name: 'Krusty', description: 'class clown', category: 'The Simpsons' },
      { name: 'Eric Cartman', description: 'the fat guy', category: 'South Park' },
      { name: 'Chef', description: 'the black guy', category: 'South Park' },
      { name: 'Token', description: 'the young black guy', category: 'South Park' },
      { name: 'Kyle', description: 'the jew', category: 'South Park' },
      { name: 'Kenny', description: 'the poor kid', category: 'South Park' },
      { name: 'Timmy', description: 'the disabled kid', category: 'South Park' },
      { name: 'Jimmy', description: 'class clown', category: 'South Park' },
    ]
    characters.each { |attributes| Character.create attributes }
  end

  def wait_until_index_is_populated
    Character.search_type.import!
    count = 10
    while Character.search_type.total_count != Character.count
      fail "index only contains #{Character.search_type.total_count} items where there should have been #{Character.count}" if count <= 0
      count -= 1
    end
  end
end
