# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_todo, mutation: Mutations::TodoMutations::CreateTodo
    field :update_todo, mutation: Mutations::TodoMutations::UpdateTodo
    field :delete_todo, mutation: Mutations::TodoMutations::DeleteTodo
  end
end
