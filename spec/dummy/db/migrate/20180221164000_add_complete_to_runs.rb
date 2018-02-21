class AddCompleteToRuns < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :complete, :boolean
  end
end
