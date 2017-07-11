class CreateEntityAttributes < ActiveRecord::Migration[5.1]
  def change
    create_table :entity_attributes do |t|
      t.references :entity, index: true
      t.integer :type, index: true
      t.integer :mode, index: true
      t.string :public_name, index: true
      t.string :private_name, index: true

      t.timestamps
    end
  end
end
