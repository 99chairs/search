require 'concerns/models/searchable'
require 'chewy'

module Searchengine
  class Engine < ::Rails::Engine

    isolate_namespace Searchengine
  end

  module Indices
    def self.all
      constants
    end

    def self.get(index_reference)
      const_get(index_reference)
    end
  end
end
