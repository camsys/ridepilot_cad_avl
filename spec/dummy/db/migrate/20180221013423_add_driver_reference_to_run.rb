class AddDriverReferenceToRun < ActiveRecord::Migration[5.1]
  def change
    add_reference :runs, :driver, index: true
  end
end
