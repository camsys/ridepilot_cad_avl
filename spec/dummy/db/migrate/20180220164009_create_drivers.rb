class CreateDrivers < ActiveRecord::Migration[5.1]
  def change
    create_table :drivers do |t|
      t.references :user, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
