# ohm-contrib

A collection of drop-in modules for Ohm.

If you're upgrading from 0.1.x, see [the changes below](#upgrade)

## Quick Overview

```ruby
require 'ohm'
require 'ohm/contrib'

class Post < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes

  attribute :amount, Type::Decimal
  attribute :url
  attribute :poster_email
  attribute :slug
end

post = Post.create

post.created_at.kind_of?(Time)
# => true

post.update_at.kind_of?(Time)
# => true
```

It's important to note that `created_at` and `update_at` both store
times as a unix timestamp for efficiency.

## Ohm::Callbacks

**Note:** Macro-style callbacks have been removed in version 1.0.x.
Please use instance style callbacks.

```ruby
class Order < Ohm::Model
  attribute :status

  def before_create
    self.status = "pending"
  end

  def after_save
    # do something here
  end
end
```

## Ohm::DataTypes

If you don't already know, Ohm 1.0 already supports typecasting out of
the box by taking a `lambda` parameter. An example best explains:

```ruby
class Product < Ohm::Model
  attribute :price, lambda { |x| x.to_f }
end
```

What `Ohm::DataTypes` does is define all of these lambdas for you,
so we don't have to manually define how to cast an Integer, Float,
Decimal, Time, Date, etc.

### DataTypes: Basic example

```ruby
class Product < Ohm::Model
  include Ohm::DataTypes

  attribute :price, Type::Decimal
  attribute :start_of_sale, Type::Time
  attribute :end_of_sale, Type::Time
  attribute :priority, Type::Integer
  attribute :rating, Type::Float
end

product = Product.create(price: "127.99")
product.price.kind_of?(BigDecimal)
# => true

product = Product.create(start_of_sale: Time.now.rfc2822)
product.start_of_sale.kind_of?(Time)
# => true

product = Product.create(end_of_sale: Time.now.rfc2822)
product.end_of_sale.kind_of?(Time)
# => true

product = Product.create(priority: "100")
product.priority.kind_of?(Integer)
# => true

product = Product.create(rating: "5.5")
product.rating.kind_of?(Float)
# => true
```

### DataTypes: Advanced example

```ruby
class Product < Ohm::Model
  include Ohm::DataTypes

  attribute :meta, Type::Hash
  attribute :sizes, Type::Array
end

product = Product.create(meta: { resolution: '1280x768', battery: '8 hours' },
                         sizes: ['XS S M L XL'])

product.meta.kind_of?(Hash)
# => true

product.meta == { resolution: '1280x768', battery: '8 hours' }
# => true

product.meta.kind_of?(Array)
# => true

product.sizes == ['XS S M L XL']
# => true
```

## Ohm::Slug

```ruby
class Post < Ohm::Model
  include Ohm::Slug

  attribute :title

  def to_s
    title
  end
end

post = Post.create(title: "Using Ohm contrib 1.0")
post.to_param == "1-using-ohm-contrib-1.0"
# => true
```

By default, `Ohm::Slug` tries to load iconv in order to transliterate
non-ascii characters.

```ruby
post = Post.create(:title => "Décor")
post.to_param == "2-decor"
```

## Ohm::Versioned

For cases where you expect people to be editing long pieces of
content concurrently (the most obvious example would be a CMS with multiple
moderators), then you need to put some kind of versioning in place.

```ruby
class Article < Ohm::Model
  include Ohm::Versioned

  attribute :title
  attribute :content
end

a1 = Article.create(:title => "Foo Bar", :content => "Lorem ipsum")
a2 = Article[a1.id]

# At this point, a2 will be stale.
a1.update(title: "Foo Bar Baz")

begin
  a2.update(:title => "Bar Baz")
rescue Ohm::VersionConflict => ex
  ex.attributes == { :title => "Bar Baz", :_version => "1", :content => "Lorem ipsum" }
  # => true
end
```

<a name="upgrade" id="upgrade"></a>

## Important Upgrade notes from 0.1.x

The following lists the major changes:

1. `Ohm::Typecast` has been removed in favor of `Ohm::DataTypes`.
2. `Ohm::Timestamping` has been renamed to `Ohm::Timestamps`.
3. `Ohm::Timestamps` now store times as a UNIX Timestamp.
4. `All Ohm validation related plugins have been removed.
    See [scrivener][scrivener] instead.
5. `Ohm::Boundaries` has been removed.
6. Ohm::Contrib no longer uses `autoload`. You can either
   `require 'ohm/contrib', which requires everything, or you
   can `require ohm/datatypes` for example if you want to cherry
   pick your requires.
7. `Ohm::Callbacks` no longer provides macro style callbacks, i.e.
   `after :create, :do_something`. Use instance callbacks instead.

[scrivener]: http://github.com/soveran/scrivener
