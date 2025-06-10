module Queries
  class Todos < Queries::BaseQuery
    type [ Types::TodoType ], null: false

    def resolve
      ::Todo.all
    end
  end

  class Todo < Queries::BaseQuery
    type Types::TodoType, null: true
    argument :id, ID, required: true

    def resolve(id:)
      ::Todo.find_by(id: id)
    end
  end
end
