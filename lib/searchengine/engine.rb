module Searchengine
  class Engine < ::Rails::Engine

    isolate_namespace Searchengine

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
