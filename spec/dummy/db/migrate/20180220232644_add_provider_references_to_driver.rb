class AddProviderReferencesToDriver < ActiveRecord::Migration[5.1]
  def change
    add_reference :drivers, :provider, index: true
  end
end
