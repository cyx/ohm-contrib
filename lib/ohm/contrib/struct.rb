# Ohm Contrib Struct
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT

require 'yaml'

module Ohm
  module Struct
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      # Store a Struct object as attributes. Accessing the attribute as
      # as named returns an instance of the struct. You can also access the
      # parameters of the struct directly as attributes.
      #
      # @example
      #
      #   Contact = Struct.new(:phone, :email)
      #
      #   class User < Ohm::Model
      #     include Ohm::Struct
      #     struct :contact, Contact
      #   end
      #
      #   user = User.create()
      #   user.contact = Contact.new("1234", "bob@wherever.blah")
      #
      #   user.contact
      #   => #<struct Contact phone="1234", email="bob@wherever.blah">
      #
      #
      #   user.contact.phone
      #   => "1234"
      #
      #   user.contact_Contact_phone
      #   => "1234"
      #
      #   user.contact_Contact_phone = "5678"
      #   => "5678"
      #
      #   user.contact.phone
      #   => "5678"
      #
      # @param [Symbol] name the name of the struct based attribute
      # @param [Class] struct the name of the struct class
      def struct(name, struct_class)
        struct_class = Ohm::Model::Wrapper.wrap(struct_class)

        define_method(name) do
          instance = struct_class.unwrap.new
          instance.members.each do |field|
            instance[field] = send(:"#{name}_#{struct_class.unwrap}_#{field}")
          end
          instance
        end
        
        define_method(:"#{name}=") do |value|
          if value.kind_of?(struct_class.unwrap)
            value.members.each do |field|
              attr = :"#{name}_#{struct_class.unwrap}_#{field}"
              self.class.class_eval("attribute(:#{attr})") unless attributes.include?(attr)
              send(:"#{attr}=", value[field])
            end
          end
        end

      end
    end
  end
end
