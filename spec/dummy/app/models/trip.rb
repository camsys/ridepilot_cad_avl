class Trip < ApplicationRecord
  belongs_to :run, optional: true
  belongs_to :provider
end
