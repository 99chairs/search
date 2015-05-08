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
  end
end
