require 'rails_helper'

RSpec.describe CharactersController, type: :controller do
  before(:all) do
    puts Chewy.configuration
    puts Chewy.massacre

    Character.search_index.create!

    characters = [
      { name: 'Julius Caesar', description: 'statesman, general', email: 'julius@caesar.it' },
      { name: 'Nero', description: 'brute', email: 'nero@rome.it' },
      { name: 'Caligula', description: 'promiscuous killer', email: 'cali@la.it' },
    ]
    characters.each { |attributes| Character.create attributes }
    Character.search_type.import! refresh: :true

#    for i in 0..10
#      if find_by_searchphrase('cali@la.it').total_count == 2
#        puts "data integrity achieved after attempt #{i}"
#        break
#      end
#    end
    puts "cali@la.it: #{find_by_searchphrase('cali@la.it').map { |r| r.attributes }}"
    puts "cali: #{find_by_searchphrase('cali').map { |r| r.attributes }}"
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
end
