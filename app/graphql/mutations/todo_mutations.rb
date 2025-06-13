# frozen_string_literal: true

module Mutations
  module TodoMutations
    class CreateTodo < Mutations::BaseMutation
      argument :title, String, required: true
      argument :description, String, required: false
      argument :status, String, required: true

      field :todo, Types::TodoType, null: true
      field :errors, [ String ], null: false

      def resolve(title:, description: nil, status:)
        todo = ::Todo.new(title: title, description: description, status: status)

        if todo.save
          Rails.cache.delete("all_todos")
          {
            todo: todo,
            errors: []
          }
        else
          {
            todo: nil,
            errors: todo.errors.full_messages
          }
        end
      end
    end

    class UpdateTodo < Mutations::BaseMutation
      argument :id, ID, required: true
      argument :title, String, required: false
      argument :description, String, required: false
      argument :status, String, required: false

      field :todo, Types::TodoType, null: true
      field :errors, [ String ], null: false

      def resolve(id:, **attributes)
        todo = ::Todo.find_by(id: id)
        return { todo: nil, errors: [ "Todo not found" ] } unless todo

        if todo.update(attributes)
          Rails.cache.delete("all_todos")
          Rails.cache.delete("todo_#{id}")
          {
            todo: todo,
            errors: []
          }
        else
          {
            todo: nil,
            errors: todo.errors.full_messages
          }
        end
      end
    end

    class DeleteTodo < Mutations::BaseMutation
      argument :id, ID, required: true

      field :success, Boolean, null: false
      field :errors, [ String ], null: false

      def resolve(id:)
        todo = ::Todo.find_by(id: id)
        return { success: false, errors: [ "Todo not found" ] } unless todo

        if todo.destroy
          Rails.cache.delete("all_todos")
          Rails.cache.delete("todo_#{id}")
          {
            success: true,
            errors: []
          }
        else
          {
            success: false,
            errors: todo.errors.full_messages
          }
        end
      end
    end
  end
end
