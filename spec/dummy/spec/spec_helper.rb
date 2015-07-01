RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10

  config.order = :random

  Kernel.srand config.seed

  def setup_dummy_dataset
    Character.destroy_all
    Chewy.massacre
    populate_dummy_dataset
    wait_until_index_is_populated
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
      { name: 'Homer Simpson', description: 'the crossed-over fat guy', category: 'Family Guy' },
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

  def destroy_dummy_dataset
    Character.destroy_all
    Chewy.massacre
  end

  def wait_until_index_is_populated
    Character.search_type.import!
    count = 10
    while Character.search_type.total_count != Character.count
      fail "index only contains #{Character.search_type.total_count} items where there should have been #{Character.count}" if count <= 0
      count -= 1
    end
  end

  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end
end
