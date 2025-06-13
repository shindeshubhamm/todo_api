module Queries
  class Todos < Queries::BaseQuery
    type [ Types::TodoType ], null: false

    def resolve
      # equivalent to Rails.cache.fetch
      cached_todos = Rails.cache.read("all_todos")

      if cached_todos.nil? # cache miss
        todos = ::Todo.all
        Rails.cache.write("all_todos", todos, expires_in: 1.hour)
        todos
      else # cache hit
        cached_todos
      end
    end
  end

  class Todo < Queries::BaseQuery
    type Types::TodoType, null: true
    argument :id, ID, required: true

    def resolve(id:)
      cached_todo = Rails.cache.read("todo_#{id}")

      if cached_todo.nil?
        todo = ::Todo.find_by(id: id)
        Rails.cache.write("todo_#{id}", todo, expires_in: 1.hour)
        todo
      else
        cached_todo
      end
    end
  end
end
