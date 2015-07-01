require 'rails_helper'

RSpec.describe Character, type: :model do
  before(:all) { setup_dummy_dataset }
  after(:all) { destroy_dummy_dataset }

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
end
