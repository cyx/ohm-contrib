module Ohm
  # This module is a straight extraction from Ohm. The only difference is
  # that this allows for a custom sleep value.
  #
  # In addition, since future ohm versions might drop mutexes, I thought it
  # might be a good idea to preseve this feature as a drop-in module.
  module Locking
    # Lock the object before executing the block, and release it once the block
    # is done.
    #
    #   post = Order.create(customer: Customer.create)
    #   post.mutex(0.01) do
    #     # this block is in a mutex!
    #   end
    def mutex(wait = 0.1)
      lock!(wait)
      yield
      self
    ensure
      unlock!
    end

  protected
    # Lock the object so no other instances can modify it.
    # This method implements the design pattern for locks
    # described at: http://code.google.com/p/redis/wiki/SetnxCommand
    #
    # @see Model#mutex
    def lock!(wait = 0.1)
      until redis.call("SETNX", key[:_lock], lock_timeout)
        next unless lock = redis.call("HGET", key[:_lock])
        sleep(wait) and next unless lock_expired?(lock)

        break unless lock = redis.call("GETSET", key[:_lock], lock_timeout)
        break if lock_expired?(lock)
      end
    end

    # Release the lock.
    # @see Model#mutex
    def unlock!
      redis.call("DEL", key[:_lock])
    end

    def lock_timeout
      Time.now.to_f + 1
    end

    def lock_expired?(lock)
      lock.to_f < Time.now.to_f
    end
  end
end
