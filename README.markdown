# ohm-contrib

A collection of drop-in modules for Ohm.

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

**Note:** Macro-style callbacks have been removed since version 1.0.x.
Please use instance style callbacks.

### On the topic of callbacks

Since I initially released ohm-contrib, a lot has changed. Initially, I
had a bad habit of putting a lot of stuff in callbacks. Nowadays, I
prefer having a workflow object or a service layer which coordinates
code not really related to the model, a perfect example of which is
photo manipulation.

It's best to keep your models pure, and have domain specific code
in a separate object.

```ruby
class Order < Ohm::Model
  include Ohm::Callbacks

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

**IMPORTANT NOTE**: Mutating a Hash and/or Array doesn't work, so you have
to re-assign them accordingly.

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

product.sizes.kind_of?(Array)
# => true

product.sizes == ['XS S M L XL']
# => true
```

## Ohm::Scope

Scope allows you to create named filters on Ohm::Set.

```ruby
class Product < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Scope
  
  attribute :in_stock, Type::Boolean
  index :in_stock
  
  scope :in_stock?, ->() { find(in_stock: true) }
  
  scope do
    def in_stock?
      find(in_stock: true)
    end
  end
end

product = Product.create(in_stock: true)
Product.all.in_stock?.first == product
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
non-ascii characters. For ruby 2 or later, you will need to `gem install iconv`
to get transliteration.

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
