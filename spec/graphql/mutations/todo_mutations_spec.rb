require 'rails_helper'

RSpec.describe 'Todo GraphQL Mutations' do
  let(:context) { {} }

  describe 'CreateTodo' do
    let(:mutation) do
      <<~GQL
        mutation CreateTodo($title: String!, $description: String, $status: String) {
          createTodo(input: { title: $title, description: $description, status: $status }) {
            todo {
              id
              title
              description
              status
            }
            errors
          }
        }
      GQL
    end

    it 'creates a todo' do
      variables = {
        title: 'Test Todo',
        description: 'Test description',
        status: 'pending'
      }

      result = TodoApiSchema.execute(mutation, variables: variables, context: context)
      data = result.dig('data', 'createTodo', 'todo')

      expect(data['title']).to eq('Test Todo')
      expect(data['status']).to eq('pending')
      expect(result['data']['createTodo']['errors']).to be_empty
    end
  end

  describe 'UpdateTodo' do
    let!(:todo) { Todo.create!(title: 'Old Title', description: 'Old Desc', status: 'pending') }

    let(:mutation) do
      <<~GQL
        mutation UpdateTodo($id: ID!, $title: String) {
          updateTodo(input: { id: $id, title: $title }) {
            todo {
              id
              title
            }
            errors
          }
        }
      GQL
    end

    it 'updates a todo' do
      variables = {
        id: todo.id,
        title: 'Updated Title'
      }

      result = TodoApiSchema.execute(mutation, variables: variables, context: context)
      data = result.dig('data', 'updateTodo', 'todo')

      expect(data['title']).to eq('Updated Title')
      expect(result['data']['updateTodo']['errors']).to be_empty
    end
  end

  describe 'DeleteTodo' do
    let!(:todo) { Todo.create!(title: 'Delete Me', status: 'pending') }

    let(:mutation) do
      <<~GQL
        mutation DeleteTodo($id: ID!) {
          deleteTodo(input: { id: $id }) {
            success
            errors
          }
        }
      GQL
    end

    it 'deletes a todo' do
      variables = { id: todo.id }

      result = TodoApiSchema.execute(mutation, variables: variables, context: context)
      success = result.dig('data', 'deleteTodo', 'success')

      expect(success).to be true
      expect(Todo.find_by(id: todo.id)).to be_nil
    end
  end
end
