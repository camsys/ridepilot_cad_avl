class CreateTrips < ActiveRecord::Migration[5.1]
  def change
    create_table :trips do |t|
      t.references :run, foreign_key: true
      t.references :provider, foreign_key: true

      t.timestamps
    end
  end
end
