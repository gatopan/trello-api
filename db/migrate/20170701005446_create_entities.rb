class CreateEntities < ActiveRecord::Migration[5.1]
  def change
    create_table :entities do |t|
      t.integer :parent_id, index: true
      t.integer :type, index: true
      t.string :private_name, index: true
      t.string :public_name, index: true
      t.integer :position, index: true
      t.uuid :uuid, index: true

      t.timestamps
    end
  end
end
