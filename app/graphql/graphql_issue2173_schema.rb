class GraphqlIssue2173Schema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
end
