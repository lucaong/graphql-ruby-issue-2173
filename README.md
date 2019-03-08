# Reproducing graphql-ruby issue 2173

This minimal Rails app is to reproduce `graphql-ruby` [issue
2173](https://github.com/rmosolgo/graphql-ruby/issues/2173).

It is a fresh Rails 5.2.2 app using the `graphql` gem and having one single model:

```ruby
# Migration:
create_table :things do |t|
  t.string :key, null: false

  t.timestamps
end

# Model:
class Thing < ApplicationRecord
end

# GraphQL object:
module Types
  class ThingType < Types::BaseObject
    field :key, String, null: true
  end
end

# GraphQL fields on QueryType:
field :things, [Types::ThingType], null: false, description: 'Get list of things by keys (show bug)' do
  argument :keys, [String], required: true
end

def things(**args)
  Rails.logger.debug("Arguments received by things: #{args.inspect}")
  ::Thing.where(key: args[:keys])
end

field :fixed_things, [Types::ThingType], null: false, description: 'Get list of things by keys (working)' do
  argument :lookup_keys, [String], required: true
end

def fixed_things(**args)
  Rails.logger.debug("Arguments received by fixed_things: #{args.inspect}")
  ::Thing.where(key: args[:lookup_keys])
end
```

The `things` and `fixed_things` fields are identical, apart from the name of the
argument, which is `keys` in one case, and `lookup_keys` in the other.

## How to reproduce the issue:

Setup and start the app:

  1. Clone the repo

  2. Install dependencies: `bundle install`

  3. Create and seed the DB: `bin/rails db:setup` (this uses `sqlite3`, to make setup super easy)

  4. Start the app: `bin/rails server`

Then open `http://localhost:3000/graphiql` and perform the following query:

```graphql
{
  things(keys: ["foo", "bar"]) {
    key
  }
  fixedThings(lookupKeys: ["foo", "bar"]) {
    key
  }
}
```

The results will be different, with `fixedThings` returning results, while
`things` not.

By looking at the Rails server logs, it can be seen that the problem is that
`things` gets called with unexpected arguments (probably due to a naming
conflict caused by the `keys` argument):

```
Arguments received by things: {:foo=>nil, :bar=>nil}
Arguments received by fixed_things: {:lookup_keys=>["foo", "bar"]}
```
