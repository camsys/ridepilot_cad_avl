class Run < ApplicationRecord
  belongs_to :provider
  belongs_to :driver, optional: true

  scope :incomplete,             -> { where('complete is NULL or complete = ?', false) }
end
