require 'rails_helper'

RSpec.describe Character, type: :model do
  before(:all) do
    Chewy.root_strategy = :urgent
    populate_dummy_dataset
    wait_until_index_is_populated
  end

  after(:all) do
    Character.destroy_all
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

  def find_by_searchphrase(phrase)
    q = { query_string: { query: "#{phrase}", analyze_wildcard: true } }
    Character.search_type.query(q)
  end

  def populate_dummy_dataset
    characters = [
      { name: 'Julius Caesar', description: 'statesman, general', email: 'julius@caesar.it' },
      { name: 'Nero', description: 'brute', email: 'nero@rome.it' },
      { name: 'Caligula', description: 'promiscuous prick', email: 'cali@la.it' },
    ]
    characters.each { |attributes| Character.create attributes }
  end

  def wait_until_index_is_populated
    Character.search_type.import!
    count = 10
    while Character.search_type.total_count != Character.count
      fail "unable to resolve" if count <= 0
      count -= 1
    end
  end
end
