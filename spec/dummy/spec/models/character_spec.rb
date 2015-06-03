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

  it 'finds Caligula by his full e-mail address' do
    expect(search_results_for('cali@la.it')).to include(a_hash_including('name' => 'Caligula'))
  end

  ['cali@la', 'cali', 'cali@', 'ali', '.it'].each do |phrase|
    it "finds Caligula by his partial e-mail address #{phrase}" do
      expect(search_results_for(phrase)).to include(a_hash_including('name' => 'Caligula'))
    end
  end

  ['*cali@la.it*', '*cali@la.it', 'cali@la.it*', 'cali*', '*i@la*', '*ali', '*@la', '*@la.it', '*.it', '*it'].each do |phrase|
    it "finds Caligula by his wildcarded e-mail address #{phrase}" do
      expect(search_results_for(phrase)).to include(a_hash_including('name' => 'Caligula'))
    end
  end

  def search_results_for(phrase)
    find_by_searchphrase(phrase).map(&:attributes)
  end

  def find_by_searchphrase(phrase)
    q = { query_string: { query: phrase, analyze_wildcard: true } }
    Character.search_type.query(q)
  end

  def populate_dummy_dataset
    characters = [
      { name: 'Julius Caesar', description: 'statesman, general', email: 'julius@caesar.it' },
      { name: 'Nero', description: 'brute', email: 'nero@rome.it' },
      { name: 'Caligula', description: 'promiscuous killer', email: 'cali@la.it' },
    ]
    characters.each { |attributes| Character.create attributes }
  end

  def wait_until_index_is_populated
    count = 0
    Character.search_type.import!
    while Character.search_type.total_count < 3
      count += 1
      if count > 10
        puts "unable to resolve" 
        exit
      end
    end
  end
end
