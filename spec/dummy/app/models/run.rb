class Run < ApplicationRecord
  belongs_to :provider
  belongs_to :driver, optional: true
end
