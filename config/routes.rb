# require 'api_constraints'

class SearchApiConstraints
  def initialize(options)
    @version = options[:version]
    @default = options[:defaults]
  end

  def matches?(req)
    @default || req.headers['Accept'].include?("application/vnd.search.v#{@version}")
  end
end

Searchengine::Engine.routes.draw do
  namespace :search, defaults: { format: 'json' } do
    scope module: :v1, constraints: SearchApiConstraints.new(version: 1) do
      # TODO: setup resource routes for every searchable controller
    end
  end
end
