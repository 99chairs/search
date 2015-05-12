module Searchengine
  class DummiesController < ActionController::Base
  end
  class Dummy < ActiveRecord::Base
    include Searchengine::Concerns::Models::Searchable

    def self.columns() @columns ||= []; end
  
    def self.column(name, sql_type=nil, default=nil, null=true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end
  
    column :email, :string
    column :name, :string
  end

  Engine.routes.draw do
    get '/search', to: 'dummies#query'
  end
end

describe Searchengine::DummiesController, type: :controller do
  before(:each) do
    Searchengine::DummiesController.class_eval do
      include Searchengine::Concerns::Controllers::Searchable
    end
  end

  routes { Searchengine::Engine.routes }

  describe 'supporting search' do
    it 'responds to the #search action' do
      get :query
      expect(response.status).to eq(200)
    end
    
    it 'calls the #process_query with the appropriate query content' do
      Searchengine::Dummy.searchable_as('Dummy') { }
      Searchengine::DummiesController.searches(Searchengine::Dummy)
      expect(controller).to receive(:process_query).with('lisa')
      get :query, q: 'lisa'
    end
  end
end
