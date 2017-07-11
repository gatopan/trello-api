module CardDecorator
  extend ActiveSupport::Concern

  def test_instance_method
    puts "holis from entity id: #{self.id} with type #{self.type}."
  end

  module ClassMethods
    def test_class_method
      puts 'class method yay'
    end
  end
end
