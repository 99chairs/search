describe 'Searchability' do
  before(:each) do
    stub_const 'Dummy', Class.new(ActiveRecord::Base)
    Dummy.class_eval do # set up a tableless model
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

    it 'provides a handler to expose managed indices' do
      expect{
        Dummy.searchable { }
      }.to change{
        Searchengine::Indices.all.count
      }.by(1)
    end

    it 'provides a handler to expose managed named indices' do
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

    context "sets the searchindex name" do
      it 'to the default name on #searchable' do
        expect{ 
          Dummy.searchable { } 
        }.to change{
          Dummy.search_index_name
        }.from(nil).to include("#{Dummy.name}Index")
      end
  
      it 'to the specified name' do
        expect{ 
          Dummy.searchable_as('Attrappe') { } 
        }.to change{
          Dummy.search_index_name
        }.from(nil).to include('AttrappeIndex')
      end
    end

    context 'with an index' do
      it 'ensures the index is known to Chewy' do
        Dummy.searchable { }
        expect(Chewy::Index.descendants).to include(Dummy.search_index)
      end
    end
  end
end
