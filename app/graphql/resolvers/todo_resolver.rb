# frozen_string_literal: true

module Resolvers
  class TodoResolver < GraphQL::Schema::Resolver
    type [Types::TodoType], null: false

    argument :status, String, required: false
    argument :search, String, required: false
    argument :sort_by, String, required: false, default_value: "created_at"
    argument :sort_direction, String, required: false, default_value: "desc"
    argument :page, Integer, required: false, default_value: 1
    argument :per_page, Integer, required: false, default_value: 10

    def resolve(status: nil, search: nil, sort_by: "created_at", sort_direction: "desc", page: 1, per_page: 10)
      todos = ::Todo.all

      # filter
      todos = todos.where(status: status) if status.present?

      # search
      todos = todos.where("title ILIKE ?", "%#{search}%") if search.present?

      # sorting
      todos = todos.order(sort_by => sort_direction)

      # pagination
      todos.offset((page - 1) * per_page).limit(per_page)
    end
  end
end 