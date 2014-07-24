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

    def changes
      hash = {}
      attributes.each do |key, value|
        if value != self.get(key)
          hash[key] = [self.get(key), value]
        end
      end
      hash
    end

    def changed_attributes
      hash = {}
      attributes.each do |key, value|
        if value != self.get(key)
          hash[key] = self.get(key)
        end
      end
      hash
    end
  end
end
