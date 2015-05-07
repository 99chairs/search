class SearchableDummyModel < ActiveRecord::Base
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type=nil, default=nil, null=true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :email, :string
  column :name, :string
end

describe 'Searchability' do
  context 'on a dummy model' do
    before do
      #stub_const 'Dummy', ActiveRecord::Base
      #Dummy.class_eval do 
      #  searchable as: 'Dumdum' do |dum| # `as: 'Dumdum'` part is optional
      #    def greet; 'hi' 
      #    field: :email, type: 'email'
      #    field: :name # defaults to string
      #  end
      #end
    end

    it 'responds to #email' do
      expect(SearchableDummyModel.new).to respond_to(:email)
    end
  end
end
