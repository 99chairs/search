class ShowsController < ApplicationController
  include Searchengine::Concerns::Controllers::Searchable
  searches 'Show'

  def index
    render json: Show.all
  end
end
