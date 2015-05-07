class SearchableDummyModel < ActiveRecord::Base
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type=nil, default=nil, null=true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :email, :string
  column :name, :string
end

module SearchableTestModels
  module Nothing
  end
end

class Strasse
  def district=(val); @district=val end
  def district; @district end
  def name=(val); @name=val end
  def name; @name end
  def self.type; 'street' end
end
class Address < Strasse
  def initialize(a,b)
    @name=a
    @number=b
  end
  def number=(val); @number=val end
  def number; @number end
  def to_s; "Address is #{name} #{number}, #{district}" end
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

    it 'interrogates objects' do
      old_address = 'Eichendorffstraße 18'
      new_address = 'Novalisstraße 12'

      klass = Class.new(Strasse)
      klass.class_eval do
        def initialize(a,b)
          @name=a
          @number=b
        end
        def to_s; "Adresse est #{name} #{@number}, #{district}" end
      end

      first = Address.new(*old_address.split)
      expect(first.class.superclass).to equal(Strasse)
      expect(first.number).to eq(old_address.split.last)
      expect(first.name).to eq(old_address.split.first)
      expect(first.class.type).to eq(Strasse.type)

      second = klass.new(*new_address.split)
      expect(second.class.superclass).to equal(Strasse)
      expect(second.name).to eq(new_address.split.first)
      expect(second.class.type).to eq(Strasse.type)
    end

    it 'is named' do
      SearchableTestModels.const_set("Dummy", Class.new(Strasse))
      #p SearchableTestModels::Dummy
    end
  end
end
