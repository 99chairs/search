class CharactersController < ApplicationController
  include Searchengine::Concerns::Controllers::Searchable
  searches 'Character'

  def index
    render json: Character.all
  end

  def query
    render json: CharactersSearchTypeService.new.query(params)
  end

  def facets
    render json: CharactersSearchTypeService.new.observe_facets
  end

  private
end

