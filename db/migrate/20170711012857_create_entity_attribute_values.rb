class CreateEntityAttributeValues < ActiveRecord::Migration[5.1]
  def change
    create_table :entity_attribute_values do |t|
      t.references :entity, index: true
      t.references :entity_attribute, index: true
      Interface::ENTITY_ATTRIBUTE_TYPES.each do |type|
        t.send(type.fetch(:postgresql_type), "#{type.fetch(:name)}_value", index: true)
      end

      t.timestamps
    end
  end
end
