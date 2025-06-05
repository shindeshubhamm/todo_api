class AddIndexToTodosTitleAndStatus < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!
  
  def change
    add_index :todos, [:title, :status], algorithm: :concurrently
  end
end
