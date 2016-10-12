module Ohm
  # The following is an example usage of this plugin:
  #
  #   class Post < Ohm::Model
  #     include Ohm::Callbacks
  #
  #   protected
  #     def before_create
  #       # sanitize the decimal values here
  #     end
  #
  #     def before_save
  #       # do something here
  #     end
  #
  #     def after_create
  #       # do twitter posting here
  #     end
  #
  #     def after_save
  #       # do something with the ids
  #     end
  #   end
  module Callbacks
    def save
      is_new = new?

      if is_new
        return false if before_create === false
      end

      if not is_new
        return false if before_update === false
      end

      return false if before_save === false

      result = super

      after_create if is_new
      after_update if not is_new
      after_save

      return result
    end

    def delete
      before_delete
      result = super
      after_delete

      return result
    end

  protected
    def before_save
    end

    def after_save
    end

    def before_create
    end

    def after_create
    end

    def before_update
    end

    def after_update
    end

    def before_delete
    end

    def after_delete
    end
  end
end
