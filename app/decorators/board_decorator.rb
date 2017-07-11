module BoardDecorator
  extend ActiveSupport::Concern

  def CARDS
    Entity.CARD.where(parent_id: self.LISTS.ids)
  end

  def test_instance_method
    puts "holis from entity id: #{self.id} with type #{self.type}."
  end

  module ClassMethods
    def test_class_method
      puts 'class method yay'
    end
  end
end
