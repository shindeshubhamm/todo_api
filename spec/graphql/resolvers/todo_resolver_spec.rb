require 'rails_helper'

RSpec.describe Resolvers::TodoResolver, type: :request do
  let(:query) do
    <<~GQL
      query GetTodos($status: String, $search: String, $sortBy: String, $sortDirection: String, $page: Int, $perPage: Int) {
        searchTodos(status: $status, search: $search, sortBy: $sortBy, sortDirection: $sortDirection, page: $page, perPage: $perPage) {
          id
          title
          description
          status
          createdAt
          updatedAt
        }
      }
    GQL
  end

  before(:each) do
    Todo.delete_all

    @todo1 = create(:todo, title: "First todo", status: "pending", created_at: 2.days.ago)
    @todo2 = create(:todo, title: "Second todo", status: "done", created_at: 1.day.ago)
    @todo3 = create(:todo, title: "Third todo", status: "pending", created_at: Time.current)

    expect(Todo.count).to eq(3)
  end

  it "returns all todos when no filters are applied" do
    result = TodoApiSchema.execute(query)
    todos = result["data"]["searchTodos"]

    expect(todos.length).to eq(3)
  end

  it "filters todos by status" do
    result = TodoApiSchema.execute(query, variables: { status: "pending" })
    todos = result["data"]["searchTodos"]

    expect(todos.length).to eq(2)
    expect(todos.map { |t| t["status"] }).to all(eq("pending"))
  end

  it "searches todos by title" do
    result = TodoApiSchema.execute(query, variables: { search: "First" })
    todos = result["data"]["searchTodos"]

    expect(todos.length).to eq(1)
    expect(todos.first["title"]).to eq("First todo")
  end

  it "sorts todos by createdAt in descending order by default" do
    result = TodoApiSchema.execute(query)
    timestamps = result["data"]["searchTodos"].map { |t| Time.parse(t["createdAt"]) }

    expect(timestamps).to eq(timestamps.sort.reverse)
  end

  it "sorts todos by createdAt in ascending order" do
    result = TodoApiSchema.execute(query, variables: { sortDirection: "asc" })
    timestamps = result["data"]["searchTodos"].map { |t| Time.parse(t["createdAt"]) }

    expect(timestamps).to eq(timestamps.sort)
  end

  it "paginates the results" do
    result = TodoApiSchema.execute(query, variables: { page: 1, perPage: 2 })
    todos = result["data"]["searchTodos"]

    expect(todos.length).to eq(2)
  end

  it "combines multiple filters" do
    result = TodoApiSchema.execute(query, variables: {
      status: "pending",
      search: "todo",
      sortDirection: "asc"
    })

    todos = result["data"]["searchTodos"]
    timestamps = todos.map { |t| Time.parse(t["createdAt"]) }

    expect(todos.length).to eq(2)
    expect(todos.map { |t| t["status"] }).to all(eq("pending"))
    expect(timestamps).to eq(timestamps.sort)
  end
end
