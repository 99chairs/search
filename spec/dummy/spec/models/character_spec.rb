require 'rails_helper'

RSpec.describe Character, type: :model do
  before(:all) do
    Chewy.massacre
    Chewy.root_strategy = :urgent

    Character.search_index.create!
  end

  after(:all) do
    Character.destroy_all
  end

  it 'has an email analyzer' do
    #puts Character.search_index.settings
  end
end
