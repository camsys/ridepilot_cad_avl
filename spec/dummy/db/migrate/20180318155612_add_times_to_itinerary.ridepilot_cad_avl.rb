# This migration comes from ridepilot_cad_avl (originally 20180318154326)
class AddTimesToItinerary < ActiveRecord::Migration[5.1]
  def change
    add_column :itineraries, :departure_time, :datetime
    add_column :itineraries, :arrival_time, :datetime
    add_column :itineraries, :finish_time, :datetime
  end
end
