class AddTimesToItinerary < ActiveRecord::Migration[5.1]
  def change
    unless column_exists? :itineraries, :departure_time
      add_column :itineraries, :departure_time, :datetime
    end
    
    unless column_exists? :itineraries, :arrival_time
      add_column :itineraries, :arrival_time, :datetime
    end

    unless column_exists? :itineraries, :finish_time
      add_column :itineraries, :finish_time, :datetime
    end
  end
end
