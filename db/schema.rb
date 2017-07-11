# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170711012917) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entities", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "type"
    t.string "private_name"
    t.string "public_name"
    t.integer "position"
    t.uuid "uuid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_entities_on_parent_id"
    t.index ["position"], name: "index_entities_on_position"
    t.index ["private_name"], name: "index_entities_on_private_name"
    t.index ["public_name"], name: "index_entities_on_public_name"
    t.index ["type"], name: "index_entities_on_type"
    t.index ["uuid"], name: "index_entities_on_uuid"
  end

  create_table "entity_attribute_values", force: :cascade do |t|
    t.bigint "entity_id"
    t.bigint "entity_attribute_id"
    t.string "string_value"
    t.text "text_value"
    t.integer "integer_value"
    t.float "float_value"
    t.boolean "boolean_value"
    t.date "date_value"
    t.datetime "datetime_value"
    t.binary "binary_value"
    t.string "symbol_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["binary_value"], name: "index_entity_attribute_values_on_binary_value"
    t.index ["boolean_value"], name: "index_entity_attribute_values_on_boolean_value"
    t.index ["date_value"], name: "index_entity_attribute_values_on_date_value"
    t.index ["datetime_value"], name: "index_entity_attribute_values_on_datetime_value"
    t.index ["entity_attribute_id"], name: "index_entity_attribute_values_on_entity_attribute_id"
    t.index ["entity_id"], name: "index_entity_attribute_values_on_entity_id"
    t.index ["float_value"], name: "index_entity_attribute_values_on_float_value"
    t.index ["integer_value"], name: "index_entity_attribute_values_on_integer_value"
    t.index ["string_value"], name: "index_entity_attribute_values_on_string_value"
    t.index ["symbol_value"], name: "index_entity_attribute_values_on_symbol_value"
    t.index ["text_value"], name: "index_entity_attribute_values_on_text_value"
  end

  create_table "entity_attributes", force: :cascade do |t|
    t.bigint "entity_id"
    t.integer "type"
    t.integer "mode"
    t.string "public_name"
    t.string "private_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_entity_attributes_on_entity_id"
    t.index ["mode"], name: "index_entity_attributes_on_mode"
    t.index ["private_name"], name: "index_entity_attributes_on_private_name"
    t.index ["public_name"], name: "index_entity_attributes_on_public_name"
    t.index ["type"], name: "index_entity_attributes_on_type"
  end

end
