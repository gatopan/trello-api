begin
  ActiveRecord::Base.transaction do
    multiverse = Entity.create!({
      type: :MULTIVERSE,
      public_name: 'Multiverse',
      private_name: 'multiverse'
    })

    ## Interface COMPANY
    interface_company = Entity.create!({
      parent_entity: multiverse,
      type: :COMPANY,
      public_name: 'Interface',
      private_name: 'interface'
    })

    ## INTERFACE COMPANY CONFIGURATION

    configuration_board = Entity.create!({
      parent_entity: interface_company,
      type: :BOARD,
      public_name: 'Configuration',
      private_name: 'configuration'
    })

    production_list = Entity.create!({
      parent_entity: configuration_board,
      type: :LIST,
      public_name: 'Production',
      private_name: 'production'
    })

    development_list = Entity.create!({
      parent_entity: configuration_board,
      type: :LIST,
      public_name: 'Development',
      private_name: 'development'
    })


    test_list = Entity.create!({
      parent_entity: configuration_board,
      type: :LIST,
      public_name: 'Test',
      private_name: 'test'
    })

    [
      { type: :symbol, private_name: :mailer_delivery_method, value: :test },
      { type: :string, private_name: :mailer_smtp_address, value: '' },
      { type: :string, private_name: :mailer_smtp_port, value: '' },
      { type: :string, private_name: :mailer_smtp_domain, value: '' },
      { type: :string, private_name: :mailer_smtp_username, value: '' },
      { type: :string, private_name: :mailer_smtp_password, value: '' },
      { type: :boolean, private_name: :mailer_smtp_authentication, value: false }
    ].each do |attribute_set|
      [
        production_list,
        development_list,
        test_list
      ].each do |environment_list|
        configuration_entity = environment_list.CARDS.create!(
          public_name: attribute_set.fetch(:private_name),
          private_name: attribute_set.fetch(:private_name)
        )
        configuration_entity.set_attribute(
          attribute_set.fetch(:type),
          :PRIVATE,
          'value'
        )
        configuration_entity.set_attribute_value(
          'value',
          attribute_set.fetch(:value)
        )
      end
    end

    ## OFFERINGS

    # products_board = Entity.create!({
    #   parent_entity: interface_company,
    #   type: :BOARD,
    #   public_name: 'products',
    #   private_name: 'products'
    # })
    #
    # courses_list = Entity.create!({
    #   parent_entity: products_board,
    #   type: :LIST,
    #   public_name: 'courses',
    #   private_name: 'courses'
    # })
    #
    # web_developer_course_card = Entity.create!({
    #   parent_entity: courses_list,
    #   type: :CARD,
    #   public_name: 'Web Developer',
    #   private_name: 'web_developer'
    # })
    #
    # tijuana_web_developer_course_card = Entity.create!({
    #   parent_entity: web_developer_course_card,
    #   type: :BOARD,
    #   public_name: 'Tijuana Web Developer Course',
    #   private_name: 'tijuana_web_developer_course'
    # })
    #
    # # success stories
    #
    # mexicali_web_developer_course_card = Entity.create!({
    #   parent_entity: web_developer_course_card,
    #   type: :BOARD,
    #   public_name: 'Mexicali Web Developer Course',
    #   private_name: 'mexicali_web_developer_course'
    # })

    ## INTERFACE COMPANY EXTERNAL BUSINESS BOARDS

    sales_board = Entity.create!({
      parent_entity: interface_company,
      type: :BOARD,
      public_name: 'Sales',
      private_name: 'sales'
    })

    [
      {
        type: :string,
        mode: :PUBLIC,
        public_name: 'Language',
        private_name: 'language'
      },
      {
        type: :string,
        mode: :PUBLIC,
        public_name: 'Email',
        private_name: 'email'
      },
      {
        type: :string,
        mode: :PUBLIC,
        public_name: 'City',
        private_name: 'city'
      },
      {
        type: :symbol,
        mode: :PUBLIC,
        public_name: 'Symbol',
        private_name: 'symbol'
      }
    ].each do |attribute_set|
      sales_board.entity_attributes.create!(attribute_set)
    end

    [
      'guests',
      'showed_interest',
      'requested_syllabus',
      'sent_application',
      'were_interviewed',
      'paid_down_payment',
      'paid_first_payment',
      'paid_second_payment',
      'did_graduate',
      'looking_for_job',
      'placed_in_job',
      'provided_testimonial'
    ].each do |private_name|
      sales_board.LISTS.create!({
        public_name: private_name.titleize,
        private_name: private_name
      })
    end

    showed_interest_list = sales_board.LISTS.find_by!(private_name: 'showed_interest')


    3.times do |i|
      opportunity_card = Entity.create!({
        parent_entity: showed_interest_list,
        type: :CARD,
        public_name: "Sample opportunity card #{i}",
        private_name: "sample_opportunity_card_#{i}"
      })

      [
        ['language', %w{english spanish}.sample],
        ['email', Faker::Internet.email],
        ['city', %w{tijuana mexicali san_diego}.sample],
        ['symbol', %w{marry me now}.sample]
      ].each do |attribute_set|
        opportunity_card.set_attribute_value(*attribute_set)
      end
    end
  end
rescue => e
  require 'pry'
  binding.pry
end
