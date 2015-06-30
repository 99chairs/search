class CharactersSearchType
  def setup
    define_type Character do
      field :name, type: 'string'
      field :email, type: 'string'
      field :description, type: 'string'
      field :category, type: 'string'
      field :category_name,
        value: ->(c) { c.category },
        type: 'string',
        index: 'not_analyzed'
    end
  end
end
