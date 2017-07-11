class EntityAttribute < ApplicationRecord
  self.inheritance_column = nil
  belongs_to :entity
  has_many :entity_attribute_values

  enum type: Interface::ENTITY_ATTRIBUTE_TYPES.map{|t| [t.fetch(:name), t.fetch(:enum_value)]}.to_h

  enum mode: {
    PRIVATE: 0,
    PUBLIC: 10,
  }

  before_validation do
    self.mode ||= :PRIVATE
  end

  validates :entity, presence: true
  validates :type, presence: true
  validates :mode, presence: true
  validates :public_name, presence: true
  validates :private_name, {
    presence: true,
    uniqueness: {
      scope: [
        :entity_id
      ]
    }
  }

  validate :private_name_convention_validation
  validate :private_name_is_not_used_by_entity_available_entity_attributes

  def private_name_is_not_used_by_entity_available_entity_attributes
    return unless entity
    return unless entity.available_entity_attributes.pluck(:private_name).include? private_name
    errors.add :private_name, 'is already being used in entity available entity attributes.'
  end

  def private_name_convention_validation
    return unless private_name
    return if private_name =~ /^[a-z0-9_]*$/
    errors.add :private_name, 'should only contain lowercase letters, numbers and underscores.'
  end

  def type=(type)
    if persisted?
      raise StandardError.new('Cannot change type of an entity attribute that is already persisted.')
    else
      super(type)
    end
  end

  def private_name=(private_name)
    if persisted?
      raise StandardError.new('Cannot change private name of an entity attribute that is already persisted.')
    else
      super(private_name)
    end
  end
end
