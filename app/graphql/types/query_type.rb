module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

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
  end
end
