module Ohm
  module Versioned
    def self.included(model)
      model.attribute :_version, ->(x) { x.to_i }
    end

    def save
      current_version = new? ? 0 : redis.call("HGET", key, :_version).to_i

      if current_version != _version
        raise Ohm::VersionConflict.new(attributes)
      end

      self._version = current_version + 1

      super
    end
  end

  class VersionConflict < StandardError
    attr :attributes

    def initialize(attributes)
      @attributes = attributes
    end
  end
end
