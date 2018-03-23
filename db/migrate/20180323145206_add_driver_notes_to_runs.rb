class AddDriverNotesToRuns < ActiveRecord::Migration[5.1]
  def change
    add_column :runs, :driver_notes, :text
  end
end
