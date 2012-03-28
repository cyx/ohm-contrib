ohm-contrib
===========

A collection of drop-in modules for Ohm. Read the full documentation at
[http://cyx.github.com/ohm-contrib](http://cyx.github.com/ohm-contrib).

List of modules
---------------
1. [`Ohm::Boundaries`](http://cyx.github.com/ohm-contrib/doc/Ohm/Boundaries.html)
2. [`Ohm::Callbacks`](http://cyx.github.com/ohm-contrib/doc/Ohm/Callbacks.html)
3. [`Ohm::Timestamping`](http://cyx.github.com/ohm-contrib/doc/Ohm/Timestamping.html)
5. [`Ohm::WebValidations`](http://cyx.github.com/ohm-contrib/doc/Ohm/WebValidations.html)
6. [`Ohm::NumberValidations`](http://cyx.github.com/ohm-contrib/doc/Ohm/NumberValidations.html)
7. [`Ohm::ExtraValidations`](http://cyx.github.com/ohm-contrib/doc/Ohm/ExtraValidations.html)
8. [`Ohm::Typecast`](http://cyx.github.com/ohm-contrib/doc/Ohm/Typecast.html)
9. [`Ohm::Locking`](http://cyx.github.com/ohm-contrib/doc/Ohm/Locking.html)

Example usage
-------------

    require 'ohm'
    require 'ohm/contrib'

    class Post < Ohm::Model
      include Ohm::Timestamping
      include Ohm::Boundaries
      include Ohm::WebValidations
      include Ohm::NumberValidations

      attribute :amount
      attribute :url
      attribute :poster_email
      attribute :slug

      def validate
        # from NumberValidations
        assert_decimal :amount

        # or if you want it to be optional
        assert_decimal :amount unless amount.to_s.empty?

        # from WebValidations
        assert_slug  :slug
        assert_url   :url
        assert_email :poster_email
      end
    end

    Post.first
    Post.last
    Post.new.to_hash
    Post.create.to_hash
    Post.create.created_at
    Post.create.updated_at

    # Casting example
    class Product
      include Ohm::Typecast

      attribute :price, Decimal
      attribute :start_of_sale, Time
      attribute :end_of_sale, Time
      attribute :priority, Integer
      attribute :rating, Float
    end

Typecasting explained
---------------------

I studied various typecasting behaviors implemented by a few ORMs in Ruby.

### ActiveRecord

    class Post < ActiveRecord::Base
      # say we have an integer column in the DB named votes
    end
    Post.new(:votes => "FooBar").votes == 0
    # => true

### DataMapper
    class Post
      include DataMapper::Resource

      property :id, Serial
      property :votes, Integer
    end

    post = Post.new(:votes => "FooBar")
    post.votes == "FooBar"
    # => true

    post.save
    post.reload

    # Get ready!!!!
    post.votes == 0
    # => true

### Ohm::Typecast approach.

#### Mindset:

1. Explosion everytime is too cumbersome.
2. Mutation of data is less than ideal (Also similar to MySQL silently allowing you
   to store more than 255 chars in a VARCHAR and then truncating that data. Yes I know
   you can configure it to be noisy but the defaults kill).
3. We just want to operate on it like it should!

#### Short Demo:
    class Post < Ohm::Model
      include Ohm::Typecast
      attribute :votes
    end

    post = Post.new(:votes => "FooBar")
    post.votes == "FooBar"
    # => true

    post.save
    post = Post[post.id]
    post.votes == "FooBar"
    # => true

    # Here comes the cool part...
    post.votes * 1
    # => ArgumentError: invalid value for Integer: "FooBar"

    post.votes = 50
    post.votes * 2 == 100
    # => true

    post.votes.class == Ohm::Types::Integer
    # => true
    post.votes.inspect == "50"
    # => true

#### More examples just to show the normal case.

    require 'ohm'
    require 'ohm/contrib'

    class Post < Ohm::Model
      include Ohm::Typecast

      attribute :price, Decimal
      attribute :available_at, Time
      attribute :stock, Integer
      attribute :address, Hash
      attribute :tags, Array
    end

    post = Post.create(:price => "10.20", :stock => "100",
                       :address => { "city" => "Boston", "country" => "US" },
                       :tags => ["redis", "ohm", "typecast"])

    post.price.to_s == "10.20"
    # => true

    post.price * 2 == 20.40
    # => true

    post.stock / 10 == 10
    # => true

    post.address["city"] == "Boston"
    post.tags.map { |tag| tag.upcase }

    # of course mutation works for both cases
    post.price += 5
    post.stock -= 1
    post.tags << "contrib"
    post.address["state"] = "MA"
    post.save
    post = Post[post.id]

    post.address["state"] == "MA"
    # => true
    post.tags.include?("contrib")
    # => true


Credits
-------
Thanks to github user gnrfan for the web validations.

Note on Patches/Pull Requests
-----------------------------
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a
  commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

Copyright
---------
Copyright (c) 2010 Cyril David. See LICENSE for details.

