require 'concerns/models/searchable'

module Searchengine
  class Engine < ::Rails::Engine

    isolate_namespace Searchengine
  end
end
