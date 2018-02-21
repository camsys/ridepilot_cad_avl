class AddDateToRuns < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :date, :date
  end
end
