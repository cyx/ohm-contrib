require_relative "datatypes"

module Ohm
  # Provides created_at / updated_at timestamps.
  #
  # @example
  #
  #   class Post < Ohm::Model
  #     include Ohm::Timestamps
  #   end
  #
  #   post = Post.create
  #   post.created_at.to_i == Time.now.utc.to_i
  #   # => true
  #
  #   post = Post[post.id]
  #   post.save
  #   post.updated_at.to_i == Time.now.utc.to_i
  #   # => true
  module Timestamps
    def self.included(model)
      model.attribute :created_at, DataTypes::Type::Timestamp
      model.attribute :updated_at, DataTypes::Type::Timestamp
    end

    def save
      self.created_at = Time.now.utc.to_i if new?
      self.updated_at = Time.now.utc.to_i

      super
    end
  end
end
