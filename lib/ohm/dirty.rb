module Ohm
  # The following is an example usage of this plugin (the methods are defined base on ActiveModel:Dirty):
  #
  #   class Post < Ohm::Model
  #     include Ohm::Callbacks
  #   end
  #
  #   post = Post[1]
  #   post.changed
  #   post.changed?
  #   post.changes
  #   post.changed_attributes
  module Dirty
    def changed
      changes.keys
    end

    def changed?
      changed.length > 0
    end

    def get_original_value(att)
      self.send(:redis).call("HGET", self.key, att)
    end

    def changes
      hash = {}
      attributes.each do |key, value|
        if value != get_original_value(key)
          hash[key] = [get_original_value(key), value]
        end
      end
      hash
    end

    def changed_attributes
      hash = {}
      attributes.each do |key, value|
        if value != get_original_value(key)
          hash[key] = get_original_value(key)
        end
      end
      hash
    end
  end
end
