# Searchengine
This Rails engine helps in configuring controllers, models and routes in order 
to expose search functionality through a simple api.

## Usage

 - Make the models searchable through the `searchable_as` helper
   - Specify the index type within the `searchable_as` block
     - Specify the searchable fields within the `define_type` block
 - Equip the controller with the `searchable` helper
 - Setup a query route
 - Populate a `config/chewy.yml` file

## Example
In the following example the controller, model and route are setup for 
searchable shows (the same examples in the `spec/dummy` app).

### Model
```ruby
class Show < ActiveRecord::Base
  include Searchengine::Concerns::Models::Searchable

  searchable_as('test') do |index|
    index.define_type Show do |type|
      type.field :name, type: 'string'
      type.field :producer, type: 'string'
    end
  end
  updatable_as('test', 'show')
end
```

Basically the ```searchable_as``` helper is used to specify the name of the index
as known in the elasticsearch store. In this example the search index is 
creatively named `test`. Furthermore, a search type is defined for the show 
model and subsequently the searchable fields of the model are specified.

### Controller
The `searches` controller helper sets up a `#query` action that allows requests
in the form ```/api/controller/query&q=blah+blah+blah``` and will return
its output in the form

```json
{
  "responseData": {
    "timeElapsed": t,
    "count": N,
    "results": [ ... ]
  }
}
```
where ```timeElapsed: t``` represents the time elapsed by elasticsearch to 
process the query and ```count: N``` represents the amount of hits found for 
the executed query.

The following snippet describes how one may equip the controller to search
through the index and type specified for the `Show` model previously.

```ruby
class ShowsController < ApplicationController
  include Searchengine::Concerns::Controllers::Searchable

  searches 'Show'

  def index
    render json: Show.all
  end
end
```

### Routes
In order to expose the action to the end-user a route needs to be setup.
Provided that the `resources` routing helper is used, one may setup the
`#query` endpoint by marking the resource collection searchable.
```ruby
Rails.application.routes.draw do
  resources :shows do
    collection do
      searchable
    end
  end
end
```

### Setup
This Rails engine uses the [Chewy gem](https://github.com/toptal/chewy) as a 
high-level interface to elasticsearch. Setup a `config/chewy.yml` file for the
application in order to dictate to the application where to find elasticsearch.

At this very moment updating of the index only works by explicitly calling the 
```create``` method on the respective index objects. This means that the call
```ruby
Show.search_index.create!
```
would set up and populate the search index in elasticsearch. Figuring out a way
to have this done as resources mutate is a work in progress, in the meantime 
one may consider running daily jobs to update all indexes through the 
```model.search_index.create!``` calls. The ```updatable_as``` model helper
does call the Chewy ```#update_index``` method, but there may be something at 
fault in the used strategies that results to no action being taken to persist
the changes in elasticsearch.

## Testing
Run the model or controller specs through the following commands:

```bash
rspec spec/controllers
rspec spec/models
```

In order to test integration, run the specs on the dummy app by entering the
dummy app directory and running the specs there:
```bash
cd spec/dummy
rspec spec
```

The dummy app implements the engine into a shows controller and Show model
features above and serves as the examples for implementing the engine in any
application.

For the sake of convenience, it is recommended to setup a [SearchBox 
Elasticsearch add-on](https://elements.heroku.com/addons/searchbox) for a 
privately owned Heroku app and update the `config/chewy.yml` to that store. 
This is being mentioned because all testing during development was done on a 
SearchBox Elasticsearch instance.

## Todo

 - clean up tests, just running ```rspec``` does not work well and ideally one wants to run all tests without having to be too specific about which tests to run
 - fix the ```#updatable_as``` model helper, somehow index updating only works after explicitly calling ```#create``` on the search index which is available through ```MODEL.search_index```.
 - make the implementation for the route helpers ```searchable``` and ```searchability_for``` more consistent. Both methods result to url helpers that are not consistently pre/post-fixed.
 - add error handling in controller action. Apparently calling ```/query``` without a ```q``` params breaks the api.
 - test with locally hosted elasticsearch store
 - determine method to test through the eventual consistency issue or mock elasticsearch. Currenly parts of the tests performs calls until a change is observed, but that is far from elegant or efficient.
