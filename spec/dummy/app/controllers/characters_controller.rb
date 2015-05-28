class CharactersController < ApplicationController
  include Searchengine::Concerns::Controllers::Searchable
  searches 'Character'

  def index
    render json: Character.all
  end
end

