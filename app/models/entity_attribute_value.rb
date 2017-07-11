class EntityAttributeValue < ApplicationRecord
  belongs_to :entity
  belongs_to :entity_attribute

  validates :entity, presence: true
  validates :entity_attribute, presence: true
  # TODO: Add context specific validation
  # Entity#create_inherited_attribute_values
  # validates :value, presence: true

  # Setter overrides
  Interface::ENTITY_ATTRIBUTE_TYPES.each do |type|
    define_method "#{type.fetch(:name)}_value=" do |value|
      return unless value

      # Casting
      value = value.to_sym if type.fetch(:name) == :symbol

      # Type checking
      unless type.fetch(:tester_proc).call(value)
        raise StandardError.new("Invalid setter value combination used. Please use `value=` or `#{self.entity_attribute.type}_value=` methods, both accept value with type of #{self.entity_attribute.type}.")
      end

      # Setting
      super(value)
    end
  end

  # Getter overrides
  def symbol_value
    return unless super
    super.to_sym
  end

  # Expose getter interface
  def value
    return unless entity_attribute
    self.send("#{entity_attribute.type}_value")
  end

  # Universal setter interface
  def value=(value)
    return unless entity_attribute
    self.send("#{entity_attribute.type}_value=", value)
  end
end
