class TodosController < ApplicationController
  before_action :set_todo, only: [ :show, :update, :destroy ]

  def index
    cached_todos = Rails.cache.read("rest_todos")

    if cached_todos.nil? # cache miss
      @todos = Todo.all
      Rails.cache.write("rest_todos", @todos, expires_in: 1.hour)
    else # cache hit
      @todos = cached_todos
    end

    render json: @todos
  end

  def show
    cached_todo = Rails.cache.read("rest_todo_#{@todo.id}")

    if cached_todo.nil? # cache miss
      Rails.cache.write("rest_todo_#{@todo.id}", @todo, expires_in: 1.hour)
    else # cache hit
      @todo = cached_todo
    end

    render json: @todo
  end

  def create
    @todo = Todo.new(todo_params)

    if @todo.save
      Rails.cache.delete("rest_todos")
      render json: @todo, status: :created
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @todo.update(todo_params)
      Rails.cache.delete("rest_todos")
      Rails.cache.delete("rest_todo_#{@todo.id}")
      render json: @todo
    else
      render json: { errors: @todo.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    todo_id = @todo.id
    @todo.destroy

    Rails.cache.delete("rest_todos")
    Rails.cache.delete("rest_todo_#{todo_id}")

    head :no_content
  end

  private

  def set_todo
    @todo = Todo.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Todo not found" }, status: :not_found
  end

  def todo_params
    params.require(:todo).permit(:title, :description, :status)
  end
end
