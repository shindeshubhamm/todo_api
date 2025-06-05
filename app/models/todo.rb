class Todo < ApplicationRecord
  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending in_progress done] }
end
