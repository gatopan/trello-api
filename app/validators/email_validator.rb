class EmailValidator < ActiveModel::EachValidator
  # http://fightingforalostcause.net/misc/2006/compare-email-regex.php
  # Thanks to James Watts and Francisco Jose Martin Moreno
  EMAIL_REGEX = /^([\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+\.)*[\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+@((((([a-z0-9]{1}[a-z0-9\-]{0,62}[a-z0-9]{1})|[a-z])\.)+[a-z]{2,6})|(\d{1,3}\.){3}\d{1,3}(\:\d{1,5})?)$/i

  def validate_each(object,attribute,value)
    if value.blank?
      object.errors[attribute] << (options[:message] || "can't be blank") unless options[:allow_blank]
    elsif !(value =~ EMAIL_REGEX)
      object.errors[attribute] << (options[:message] || "is not a valid email address")
    end
  end
end
