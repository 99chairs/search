
describe 'Searchability' do
  before(:each) do
    stub_const 'Dummy', Class.new(ActiveRecord::Base)
    Chewy.root_strategy = :urgent
    Dummy.class_eval do # set up a tableless model
      require 'activerecord-tableless'

      has_no_table database: :pretend_success
      def self.columns() @columns ||= []; end
    
      def self.column(name, sql_type=nil, default=nil, null=true)
        columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
      end
    
      column :email, :string
      column :name, :string
    end
  end

  context 'on a dummy model' do
    before(:each) do
      Dummy.class_eval do
        include Searchengine::Concerns::Models::Searchable
      end
    end

    it 'exposes the searchability descriptors' do
      expect(Dummy).to respond_to(:searchable_as)
      expect(Dummy).to respond_to(:searchable)
    end

    it 'creates a search index for searchable models' do
      expect{
        Dummy.searchable { }
      }.to change{
        Searchengine::Indices.all.count
      }.by(1)
    end

    it 'creates a search index for named searchable models' do
      expect {
        Dummy.searchable_as('Unoccupied') { |i| p "incoming #{i}" }
      }.to change{
        Searchengine::Indices.all.count
      }.by(1)
    end

    it 'is oblivious to non searchengine indices' do
      expect{
        stub_const 'Bubblegum', Class.new(Chewy::Index)
      }.to change{
        Searchengine::Indices.all.count
      }.by(0)
    end

    it 'provides a handler to retrieve managed indices' do
      Dummy.searchable { }
      idx_sym = Searchengine::Indices.all.first
      expect(Searchengine::Indices.get(idx_sym)).to eq(Searchengine::Indices::DummyIndex)
    end

    context "names the index" do
      it 'after the model by default' do
        expect{ 
          Dummy.searchable { } 
        }.to change{
          Dummy.search_index_name
        }.from(nil).to include("#{Dummy.name}Index")
      end
  
      it 'after the specified input' do
        expect{ 
          Dummy.searchable_as('Attrappe') { } 
        }.to change{
          Dummy.search_index_name
        }.from(nil).to include('AttrappeIndex')
      end

      it 'after the camelized variant of the specified input' do
        expect{ 
          Dummy.searchable_as('great_knowledge') { } 
        }.to change{
          Dummy.search_index_name
        }.from(nil).to include('GreatKnowledge')
      end

      it 'sets up the #update_index proc' do
        expect(Dummy).to receive(:update_index).with('/searchengine/indices/index#type')
        Dummy.updatable_as('index', 'type')
      end
    end

    context 'with an index' do
      before(:each) do
        Dummy.class_eval do
          searchable_as :sandbox do |index|
            index.define_type Dummy do |type|
              type.field :email, :string
              type.field :name, :string
            end
          end
          updatable_as :sandbox, :dummy
        end
        Dummy.search_index.purge!
      end

      it 'ensures the index is known to Chewy' do
        Dummy.searchable { }
        expect(Chewy::Index.descendants).to include(Dummy.search_index)
      end

      it 'adds items to the index' do
        filter = Dummy.search_index.filter do
          q(query_string: { query: '*stew*' } ) 
        end
        expect {
          Dummy.create(email: 'stewie@griffin.qh', name: 'Steward')
          Dummy.create(email: 'cook@delistews.kitchen', name: 'Delish Stews')
        }.to change{ filter.total_count }.by(2)
      end
    end
  end
end
