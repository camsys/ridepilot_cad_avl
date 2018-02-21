class CreateRuns < ActiveRecord::Migration[5.1]
  def change
    create_table :runs do |t|
      t.references :provider
      t.string :name

      t.timestamps
    end
  end
end
