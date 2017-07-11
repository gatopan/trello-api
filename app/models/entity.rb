class Entity < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :parent_entity, {
    class_name: 'Entity',
    foreign_key: :parent_id,
    optional: true
  }
  has_many :children_entities, {
    class_name: 'Entity',
    foreign_key: :parent_id
  }
  has_many :entity_attributes
  has_many :entity_attribute_values

  enum type: Interface::ENTITY_TYPES

  after_save :create_inherited_attribute_values

  # NOTE: Used to remove excessive `children_entities` calls
  Interface::ENTITY_TYPES.keys.each do |type, number|
    define_method type.to_s.pluralize.upcase do
      self.children_entities.where(
        type: self.class.types[type]
      )
    end
  end

  before_validation do
    if persisted?
      # STUB
    else
      self.private_name ||= calculated_private_name
      self.position = calculated_position
      self.uuid = calculated_uuid
    end
  end

  validates :parent_entity, presence: true, if: Proc.new{|i| i.class.any? }
  validates :type, presence: true
  validates :public_name, presence: true
  validates :private_name, {
    presence: true,
    uniqueness: {
      scope: [
        :parent_id,
        :type
      ]
    }
  }
  validates :position, {
    presence: true,
    uniqueness: {
      scope: [
        :parent_id,
        :type
      ]
    }
  }
  validates :uuid, {
    presence: true,
    uniqueness: true
  }

  ## POLICIES VALIDATIONS
  validate :type_compatibility_check
  validate :item_board_congruence
  validate :private_name_convention_validation

  after_initialize :decorate_myself

  def decorator_name
    return unless type
    "#{self.type.capitalize}Decorator"
  end

  def decorator
    return unless decorator_name
    decorator_name.constantize
  rescue
    raise StandardError.new("Decorator `#{decorator_name}` not found.")
  end

  def decorate_myself
    return unless type

    self.class_eval <<~eoruby, __FILE__, __LINE__ + 1
      include(#{decorator})
    eoruby
  end

  # NOTE: Added enum key value lookup
  def self.where_override(prefiltered_options, *rest)
    filtered_options = prefiltered_options.map do |key, value|
      values = self.defined_enums.fetch(key.to_s, nil)
      value = values ? values.fetch(value, nil) : value
      [key, value]
    end.to_h

    binding.pry

    super(filtered_options, rest)
  end

  # alias_method :where_override, :where, :where!, :having, :having!, :not

  def private_name_convention_validation
    return unless private_name
    return if private_name =~ /^[a-z0-9_]*$/
    errors.add :private_name, 'only allows lowercase letters, numbers and underscores.'
  end

  def private_name=(private_name)
    if persisted?
      raise StandardError.new('Cannot change private name of an entity that is already persisted.')
    else
      super(private_name)
    end
  end

  ## SIBLINGS

  def sibling_entities
    self.class
      .where(parent_entity: parent_entity)
      .where(type: self.class.types[type]) # TODO: bitten by enum sql, must implement scope enum filter
      .order(:position)
  end

  def previous_sibling_entities
    if persisted?
      sibling_entities
        .where("position < (?)", position)
        .order(:position)
    else
      sibling_entities
    end
  end

  def next_sibling_entities
    if persisted?
      sibling_entities
        .where("position > (?)", position)
        .order(:position)
    else
      sibling_entities
        .where(id: 0)
    end
  end

  def previous_sibling_entity(offset = 1)
    if persisted?
      sibling_entities.find_by(position: position - offset)
    else
      raise StandardError.new('Tried to calculate previous sibling entity of an entity that is not persisted.')
    end
  end

  def next_sibling_entity(offset = 1)
    if persisted?
      sibling_entities.find_by(position: position + offset) || self.class.new
    else
      raise StandardError.new('Tried to calculate next sibling entity of an entity that is not persisted.')
    end
  end

  ## POSITIONING

  def move_to_position(target_position)
    raise StandardError.new('Tried to move an entity that is not persisted.') unless persisted?
    return true if target_position == self.position
    raise StandardError.new('Tried to move an entity beyond allowed limits.') if target_position < 0
    raise StandardError.new('Tried to move an entity beyond allowed limits.') if target_position >= sibling_entities.count

    if target_position < self.position
      perform_move(
        :+,
        target_position,
        sibling_entities
          .where(position: target_position..(self.position - 1))
          .order(position: :desc)
      )
    else
      perform_move(
        :-,
        target_position,
        sibling_entities
          .where(position: (self.position + 1)..target_position)
          .order(position: :asc)
      )
    end
  end

  def move_to_previous_position
    raise StandardError.new('Tried to move an entity that is not persisted.') unless persisted?
    target_position = self.position - 1
    raise StandardError.new('Tried to move an entity beyond allowed limits.') if position < 0
    raise StandardError.new('Tried to move an entity beyond allowed limits.') if target_position >= sibling_entities.count
    perform_move(
      :+,
      target_position,
      sibling_entities.where(position: target_position)
    )
  end

  def move_to_next_position
    raise StandardError.new('Tried to move an entity that is not persisted.') unless persisted?
    target_position = self.position + 1
    raise StandardError.new('Tried to move an entity beyond allowed limits.') if target_position < 0
    raise StandardError.new('Tried to move an entity beyond allowed limits.') if target_position >= sibling_entities.count
    perform_move(
      :-,
      target_position,
      sibling_entities.where(position: target_position)
    )
  end

  def move_to_first_position
    raise StandardError.new('Tried to move an entity that is not persisted.') unless persisted?
    perform_move(
      :+,
      0,
      self.previous_sibling_entities.order(position: :desc)
    )
  end

  def move_to_last_position
    raise StandardError.new('Tried to move an entity that is not persisted.') unless persisted?
    perform_move(
      :-,
      self.sibling_entities.count - 1,
      self.next_sibling_entities.order(position: :asc)
    )
  end

  def perform_move(shift_operator, target_position, affected_entities)
    self.class.transaction do
      self.update_column('position', -1)
      affected_entities.each do |affected_entity|
        new_position = affected_entity.position.send(shift_operator, 1)
        affected_entity.update_column('position', new_position)
      end
      self.update_column('position', target_position)
    end
  end

  # TODO: Find out why it doesn't find parent entity when scoped
  def parent_entity
    self.class.unscoped.find_by(id: self.parent_id)
  end

  # NOTE: Entity attributes propagation
  def available_entity_attributes
    available_entity_attributes_ids = self.entity_attributes.ids
    target_entity = self.parent_entity

    loop do
      if target_entity
        available_entity_attributes_ids = available_entity_attributes_ids + target_entity.entity_attributes.PUBLIC.ids
        target_entity = target_entity.parent_entity
      else
        break
      end
    end

    EntityAttribute.where(id: available_entity_attributes_ids)
  end

  def create_inherited_attribute_values
    self.available_entity_attributes.each do |entity_attribute|
      self.entity_attribute_values.find_or_create_by(entity_attribute: entity_attribute)
    end
  end

  # Entity Attributes
  def set_attribute(type, mode, private_name)
    entity_attribute = self.entity_attributes.create!(
      type: type,
      mode: mode,
      private_name: private_name,
      public_name: public_name.humanize
    )
    self.entity_attribute_values.create!(
      entity_attribute: entity_attribute
    )
  end

  def get_attribute(private_name)
    self.entity_attributes.find_by!(private_name: private_name)
  end

  # Entity Attributes Values
  def set_attribute_value(private_name, value)
    entity_attribute = self.available_entity_attributes.find_by!(private_name: private_name)
    entity_attribute_value = self.entity_attribute_values.find_by!(entity_attribute: entity_attribute)
    entity_attribute_value.value = value
    entity_attribute_value.save ? entity_attribute_value.value : nil
  end

  def get_attribute_value(private_name)
    entity_attribute = get_attribute(private_name)
    entity_attribute_value = self.entity_attribute_values.find_by(entity_attribute: entity_attribute)
    entity_attribute_value ? entity_attribute_value.value : nil
  end

  ## FOR DEBUGGGING ONLY
  if Rails.env == 'development'
    def dynamic_attributes
      self.entity_attribute_values.map do |entity_attribute_value|
        [
          entity_attribute_value.entity_attribute.private_name,
          entity_attribute_value.value
        ]
      end.to_h.symbolize_keys
    end
  end

  # POLICY - enforce children entity and parent entity type compatibility
  # Board can only have company or item parent
  # List can only have board parent
  # Card can only have list parent
  # Item can only have card parent
  def type_compatibility_check
    return unless type
    return unless parent_entity || self.MULTIVERSE?
    return if case type
    when 'MULTIVERSE' then true
    when 'PERSON' then parent_entity.MULTIVERSE?
    when 'COMPANY' then parent_entity.MULTIVERSE?
    when 'BOARD' then parent_entity.COMPANY? || parent_entity.ITEM?
    when 'LIST' then parent_entity.BOARD?
    when 'CARD' then parent_entity.LIST?
    when 'ITEM' then parent_entity.CARD?
    end

    errors.add :type, 'is incompatible with parent type.'
  end

  # POLICY - only one board per item check
  def item_board_congruence
    if self.BOARD? && parent_entity.ITEM?
      if parent_entity.BOARDS.count > 0
        errors.add :parent, 'already has a board linked.'
      end
    end
  end

  # MECHANISM - Calculate unique private name that will be used during creation
  # in case none is assigned
  def calculated_private_name
    calculated_private_name = nil

    loop do
      calculated_private_name = SecureRandom.uuid.first(8)
      break unless self.class.exists?(private_name: calculated_private_name)
    end

    calculated_private_name
  end

  # MECHANISM - Calculate position based on sibling entities count
  def calculated_position
    sibling_entities.count
  end

  # MECHANISM - Calculate unique id that will be used during creation
  def calculated_uuid
    calculated_uuid = nil

    loop do
      calculated_uuid = SecureRandom.uuid
      break unless self.class.exists?(uuid: calculated_uuid)
    end

    calculated_uuid
  end

  ## TODO: Below

  # sales_board.CARDS.where_attribute_value(email: self.email)
  # sales_board.CARDS.find_by_attribute_value!(email: self.email)

  # TODO:
  # - Add multiple terms ( self.where_attribute_value(*options) )
  # - Optimize propagation lookup in SQL
  # - Optimize value search based on type in SQL
  def self.where_attribute_value(private_name, value)
    entities                = current_scope || relation
    final_entity_ids        = []
    entity_attributes_ids   = []

    entities.each do |entity|
      entity_attributes_ids = entity_attributes_ids + entity.available_entity_attributes.where(private_name: private_name).ids
    end

    entity_attributes       = EntityAttribute.where(id: entity_attributes_ids)
    entity_attribute_values = EntityAttributeValue.where(entity: entities, entity_attribute: entity_attributes)

    entity_attribute_values.each do |entity_attribute_value|
      if entity_attribute_value.value == value
        final_entity_ids << entity_attribute_value.entity_id
      end
    end

    Entity.where(id: final_entity_ids)
  end

  def self.find_by_attribute_value(private_name, value)
    where_attribute_value(private_name, value).first
  end

  def self.find_by_attribute_value!(private_name, value)
    record = find_by_attribute_value(private_name, value)

    if record
      record
    else
      raise StandardError.new('Did not find any record with that attribute and value')
    end
  end
end
