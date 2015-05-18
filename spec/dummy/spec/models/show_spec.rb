require 'rails_helper'

RSpec.describe Show, type: :model do
  before(:all) do
    Chewy.massacre
    Chewy.root_strategy = :urgent

    Show.search_index.create!
    Show.create name: 'Family Guy', producer: 'Seth MacFarlane', piloted_at: DateTime.now
    Show.create name: 'American Dad', producer: 'Seth MacFarlane', piloted_at: DateTime.now
    Show.create name: 'Cleveland Show', producer: 'Seth MacFarlane', piloted_at: DateTime.now
    Show.create name: 'Scandal', producer: 'Shonda Rhimes', piloted_at: DateTime.now
    Show.create name: 'Das Boot', producer: 'Günter Rohrbach', piloted_at: DateTime.now
  end

  after(:all) do
    Show.destroy_all
  end

  it 'has an index' do
    expect(Show.search_index).to be(Searchengine::Indices::TestIndex)
  end

  it 'has a type' do
    expect(Show.search_type).to be(Searchengine::Indices::TestIndex::Show)
  end

  context 'imports' do
    let(:q) { { query_string: { query: '*unit*' } } }

    it 'existing resources into search index' do
      expect{ 
        Show.create(name: 'The Unit', producer: 'David Mamet', piloted_at: DateTime.now)
        Show.search_type.import! refresh: true
        # TODO: figure out a nicer way to test this, perhap mock ES altogether
        10.times.each { puts Show.search_type.query(q).total_count }
      }.to change{
        Show.search_type.query(q).total_count
      }.by(1)
    end
  end

  context 'strategy #update' do
    before do
      stub_const('Chewy::Strategy::Mock', Class.new(Chewy::Strategy::Base) {
        puts "stubbing #update on #{self}"
        def update type, objects, options={}
          puts "selfie #{self.class} HERE"
          #super type, objects, options
        end
      })
      Chewy.root_strategy = :mock
    end

    it 'is triggered upon save' do
      puts "thread is #{Thread.current[:chewy_strategy]}"
      skip
      expect_any_instance_of(Chewy::Strategy::Mock).to receive(:update)
      Show.create! name: 'The Unit', producer: 'David Mamet', piloted_at: DateTime.now
    end

    it 'is triggered upon save in strategy block' do
      skip
      strategy = Thread.current[:chewy_strategy]
      Chewy::Strategy.class_eval do
        def stack
          @stack
        end
      end
      Chewy::Strategy::Urgent.class_eval do
        def update
          puts "UPDATING"
        end
      end
      puts "@stack is #{strategy.stack}"
      Chewy.strategy(:urgent) do
        Show.create! name: 'The Simpsons', producer: 'Matt Groening', piloted_at: DateTime.now
      end
      puts "@stack is #{strategy.stack}"
      expect_any_instance_of(Chewy::Strategy::Base).to receive(:update)
    end

    it 'is triggered upon update'
  end
end
