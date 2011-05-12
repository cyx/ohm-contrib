# Ohm Contrib Looseref
#
# Copyright (c) 2011 Phil Stewart
#
# License: MIT

module Ohm
  module Looseref
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      # Defines a loose reference to another model. Objects pointed to by a
      # looseref can either by of the model class used in the definition or
      # any of that model's subclasses.
      #
      # @example
      #
      #   class ParentClass < Ohm::Model
      #   end
      #
      #   class SubClass < ParentClass
      #     attribute :insubonly
      #   end
      #
      #   class ReferringClass < Ohm::Model
      #     include Ohm::Looseref
      #     looseref :parent_or_sub, ParentClass
      #   end
      #
      #   referring = ReferringClass.create()
      #
      #   referring.parent_or_sub = ParentClass.create()
      #   referring.parent_or_sub.insubonly
      #   # => NoMethodError
      #
      #   referring.parent_or_sub = SubClass.create(:insubonly => 1)
      #   referring.parent_or_sub.insubonly
      #   # => "1"
      #
      # @param [Symbol] name the name of the reference to define.
      # @param [Class] model the name of the top level model. Objects pointed
      #                to by the looseref are either of this class or one of
      #                its subclasses.
      def looseref(name, model)
        model = Ohm::Model::Wrapper.wrap(model)

        reader_id = :"#{name}_id"
        reader_klass = :"#{name}_klass"
        writer_id = :"#{name}_id="
        writer_klass = :"#{name}_klass="

        attributes << reader_id unless attributes.include?(reader_id)
        attributes << reader_klass unless attributes.include?(reader_klass)

        index reader_id

        define_method(name) do
          Object.const_get(send(reader_klass).to_sym)[send(reader_id)]
        end

        define_method(:"#{name}=") do |value|
          if value.kind_of?(model.unwrap)
            send(writer_id, value ? value.id : nil)
            send(writer_klass, value ? value.class.to_s : nil)
          end
        end

        define_method(reader_id) do
          read_local(reader_id)
        end

        define_method(reader_klass) do
          read_local(reader_klass)
        end

        define_method(writer_id) do |value|
          write_local(reader_id, value)
        end

        define_method(writer_klass) do |value|
          write_local(reader_klass, value)
        end
        
        true
      end
    end
  end
end
