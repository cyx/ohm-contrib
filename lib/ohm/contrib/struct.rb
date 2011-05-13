# Ohm Contrib Struct
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT

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
      #   # => #<struct Contact phone="1234", email="bob@wherever.blah">
      #
      #
      #   user.contact.phone
      #   # => "1234"
      #
      #   user.contact_Contact_phone
      #   # => "1234"
      #
      #   user.contact_Contact_phone = "5678"
      #   # => "5678"
      #
      #   user.contact.phone
      #   # => "5678"
      #
      # @param [Symbol] name the name of the struct based attribute
      # @param [Class] struct the name of the struct class
      def struct(name, struct_class)
        struct_class = Ohm::Model::Wrapper.wrap(struct_class)

        # Struct attribute reader
        define_method(name) do
          struct_instance = struct_class.unwrap.new
          model_instance = self
          struct_instance.members.each do |field|
            attr = send(:"#{name}_attr", field)
            struct_instance[field] = send(attr)
            # Override the field assignment method in the struct instance to
            # provide a callback to the corresponding attribute writer
            struct_instance.define_singleton_method(:"#{field}=") do |value|              
              super(value)
              model_instance.send(:"#{attr}=", value)
            end
          end
          struct_instance
        end
        
        # Struct attribute writer
        define_method(:"#{name}=") do |value|
          if value.kind_of?(struct_class.unwrap)
            value.members.each do |field|
              attr = send(:"#{name}_attr", field)
              send(:"#{attr}=", value[field])
            end
          end
        end

        # Returns the attribute name corresponding to the passed field, and
        # ensures the attribute is defined
        define_method(:"#{name}_attr") do |field|
          attr = :"#{name}_#{struct_class.unwrap}_#{field}"
          self.class.class_eval("attribute(:#{attr})") unless attributes.include?(attr)
          attr
        end

      end
    end
  end
end
