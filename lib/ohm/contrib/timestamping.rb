module Ohm
  # Provides created_at / updated_at timestamps.
  #
  # @example
  #
  #   class Post < Ohm::Model
  #     include Ohm::Timestamping
  #   end
  #
  #   post = Post.create
  #   post.created_at.to_s == Time.now.utc.to_s
  #   # => true
  #
  #   post = Post[post.id]
  #   post.save
  #   post.updated_at.to_s == Time.now.utc.to_s
  #   # => true
  module Timestamping
    def self.included(base)
      base.attribute :created_at
      base.attribute :updated_at
    end

    def create
      self.created_at ||= Time.now.utc.to_i

      super
    end

  protected
    def write
      self.updated_at = Time.now.utc.to_i

      super
    end
  end
end

