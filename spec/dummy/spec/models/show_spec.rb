require 'rails_helper'

RSpec.describe Show, type: :model do
  before(:all) do
    Chewy.massacre

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
    expect(Show.search_index).to be(Searchengine::Indices::FehrsehenIndex)
  end

  it 'has a type' do
    expect(Show.search_type).to be(Searchengine::Indices::FehrsehenIndex::Show)
  end

  it 'has a chewy setup' do
    puts "Chewy config is #{Chewy.config.configuration}"
  end

  it 'creates a item' do
    puts Chewy.root_strategy
    puts Show.all.count
    show = Show.create name: 'Family Guy', producer: 'Seth MacFarlane', piloted_at: DateTime.now
    show.piloted_at = DateTime.new(1999, 1, 31, 18, 32)
    show.save
    puts Show.all.count
  end

  context 'imports' do
    let(:q) { { query_string: { query: 'seth*' } } }
    it 'existing resources into search index' do
      expect{ 
        Show.search_type.import! refresh: true
        10.times.each { Show.search_type.query(q).total_count }
      }.to change{
        Show.search_type.query(query_string: { query: 'seth*' }).total_count
      }.by(3)
    end

    it 'creates a new show' do
      p "B #{Show.search_type.query(query_string: { query: 'seth*' }).total_count}"
      begin
        Show.create(name: "Fringe")
      rescue => e
        puts "broke on #{e}"
      end
    end
  end

  context 'strategy #update' do
    before { stub_const('Movie', Class.new(ActiveRecord::Base) {
      update_index('cities#city', :self)
    }) }
    before { stub_const('MoviesIndex', Class.new(Chewy::Index) {
      define_type Movie
    }) }

    before { stub_const('Chewy::Strategy::Mock', Class.new(Chewy::Strategy::Base) {
      def update type, objects, options={}
        puts "selfie #{self.class} HERE"
        #super type, objects, options
      end
    }) }

    it 'calls update on the strategy upon safe' do
      p "C #{Show.search_type.query(query_string: { query: 'seth*' }).total_count}"
      skip
      expect_any_instance_of(@item).to receive(:update)
      Movie.create!
    end

    it 'is triggered upon save' do
      skip
      expect_any_instance_of(Chewy::Strategy::Mock).to receive(:update)
      Chewy.strategy(:mock) do
        Show.create! name: 'The Simpsons', producer: 'Matt Groening', piloted_at: DateTime.now
      end
      puts "root=#{Chewy.root_strategy} strat=#{Chewy.strategy}"
    end

    it 'is triggered upon update' do
      skip
      expect_any_instance_of(Chewy::Strategy::Mock).to receive(:update)
      puts "STRATEGY IS #{Chewy.root_strategy}"
      #stub_const 'Movie', Class.new(ActiveRecord::Base) { update_index 'movies#movie', :self }
      #stub_const 'MoviesIndex', Class.new(Chewy::Index) { define_type Movie }
      Chewy.strategy(:mock) do
        Show.create! name: 'Fringe', producer: 'J.J. Abrams', piloted_at: DateTime.now
      end
    end
  end
end
