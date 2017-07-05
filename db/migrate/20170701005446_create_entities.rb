class CreateEntities < ActiveRecord::Migration[5.1]
  def change
    create_table :entities do |t|

      t.timestamps
    end
  end
end
