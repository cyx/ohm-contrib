# encoding: utf-8

require File.expand_path("../helper", __FILE__)
require 'set'

class Comment < Ohm::Model
  include Ohm::Timestamps
end

test "timestamps are added during creation" do
  e = Comment.new
  e.save

  assert e.created_at
  assert e.updated_at
end

class Server < Ohm::Model
  include Ohm::Locking
end

test "mutex method is added at instance and class level" do
  assert Server.new.respond_to?(:mutex)
end

class Article < Ohm::Model
  include Ohm::Callbacks

  attribute :title
  set :comments, Comment

private
  def before_save
    self.title = title.gsub("<br>", " ")
  end

  def after_save
    comments.key.sadd(Comment.create.id)
  end
end

test "class-level, instance level callbacks" do
  a = Article.create(:title => "Foo<br>Bar")

  assert_equal "Foo Bar", a.title
  assert_equal 1, a.comments.size
end

# slugging
scope do
  class Post < Ohm::Model
    attribute :title

    include Ohm::Slug

    def to_s
      title
    end
  end

  test "slugging" do
    post = Post.create(:title => "Foo Bar Baz 1.0")
    assert_equal "1-foo-bar-baz-1-0", post.to_param

    post = Post.create(:title => "Décor")
    assert_equal "2-decor", post.to_param
  end
end

# Ohm::Scope
scope do
  class Order < Ohm::Model
    include Ohm::Scope

    attribute :state
    index :state

    attribute :deleted
    index :deleted

    scope do
      def paid
        find(:state => "paid")
      end

      def deleted
        find(:deleted => 1)
      end
    end
  end

  test "scoping" do
    paid = Order.create(:state => "paid", :deleted => nil)

    assert Order.all.paid.include?(paid)
    assert_equal 0, Order.all.paid.deleted.size

    paid.update(:deleted => 1)
    assert Order.all.paid.deleted.include?(paid)
  end
end

# soft delete
scope do
  class User < Ohm::Model
    include Ohm::SoftDelete

    attribute :email
    index :email
  end

  setup do
    user = User.create(:email => "a@a.com")
    user.delete

    user
  end

  test "removes from User.all" do |user|
    assert User.all.empty?
  end

  test "adds to User.deleted" do |user|
    assert User.deleted.include?(user)
  end

  test "doesn't remove from indices" do |user|
    assert User.find(:email => "a@a.com").include?(user)
  end

  test "makes it deleted?" do |user|
    assert user.deleted?
  end

  test "is still retrievable" do |user|
    assert_equal user, User[user.id]
  end

  test "restore" do |user|
    user.restore

    assert User.all.include?(user)
    assert User.deleted.empty?

    assert ! user.deleted?
  end
end

# datatypes
scope do
  class Product < Ohm::Model
    include Ohm::DataTypes

    attribute :name
    attribute :stock, Type::Integer
    attribute :price, Type::Decimal
    attribute :rating, Type::Float
    attribute :bought_at, Type::Time
    attribute :date_released, Type::Date
    attribute :sizes, Type::Hash
    attribute :stores, Type::Array
    attribute :published, Type::Boolean
    attribute :state, Type::Symbol
    attribute :comments, Type::Set
  end

  test "Type::Integer" do
    p = Product.new(:stock => "1")

    assert_equal 1, p.stock
    p.save

    p = Product[p.id]
    assert_equal 1, p.stock
  end

  test "Type::Time" do
    time = Time.utc(2011, 11, 22)
    p = Product.new(:bought_at => time)
    assert p.bought_at.kind_of?(Time)

    p.save

    p = Product[p.id]
    assert p.bought_at.kind_of?(Time)
    assert_equal time, p.bought_at

    assert_equal "2011-11-22 00:00:00 UTC", p.key.hget(:bought_at)
    assert_equal "2011-11-22 00:00:00 UTC", p.bought_at.to_s
  end

  test "Type::Date" do
    p = Product.new(:date_released => Date.today)

    assert p.date_released.kind_of?(Date)

    p = Product.new(:date_released => "2011-11-22")
    assert p.date_released.kind_of?(Date)

    p.save

    p = Product[p.id]
    assert_equal Date.new(2011, 11, 22), p.date_released
    assert_equal "2011-11-22", p.key.hget(:date_released)
    assert_equal "2011-11-22", p.date_released.to_s
  end

  test "Type::Hash" do
    sizes = { "XS" => 1, "S" => 2, "L" => 3 }

    p = Product.new(:sizes => sizes)
    assert p.sizes.kind_of?(Hash)
    p.save

    p = Product[p.id]
    assert_equal sizes, p.sizes
    assert_equal %Q[{"XS":1,"S":2,"L":3}], p.key.hget(:sizes)
    assert_equal %Q[{"XS":1,"S":2,"L":3}], p.sizes.to_s
  end

  test "Type::Array" do
    stores = ["walmart", "marshalls", "jcpenny"]
    p = Product.new(:stores => stores)
    assert p.stores.kind_of?(Array)

    p.save

    p = Product[p.id]
    assert_equal stores, p.stores
    assert_equal %Q(["walmart","marshalls","jcpenny"]), p.key.hget(:stores)
    assert_equal %Q(["walmart","marshalls","jcpenny"]), p.stores.to_s
  end

  test "Type::Decimal" do
    p = Product.new(:price => 0.001)

    # This fails if 0.001 is a float.
    x = 0
    1000.times { x += p.price }
    assert_equal 1, x

    p.save

    p = Product[p.id]
    assert_equal 0.001, p.price
    assert_equal "0.1E-2", p.key.hget(:price)
  end

  test "Type::Float" do
    p = Product.new(:rating => 4.5)
    assert p.rating.kind_of?(Float)

    p.save
    p = Product[p.id]
    assert_equal 4.5, p.rating
    assert_equal "4.5", p.key.hget(:rating)
  end

  test "Type::Boolean" do
    p = Product.new(:published => 1)
    assert_equal true, p.published

    p.save

    p = Product[p.id]
    assert_equal true, p.published

    p.published = false
    p.save

    p = Product[p.id]
    assert_equal "false", p.key.hget(:published)
    assert_equal false, p.published
  end

  test "Type::Symbol" do
    p = Product.new(:state => 'available')

    assert_equal :available, p.state
    p.save

    p = Product[p.id]
    assert_equal :available, p.state
  end

  test "Type::Set" do
    comments = ::Set.new(["Good product", "Awesome!", "Great."])
    p = Product.new(:comments => comments)
    puts p.comments.class.superclass.name
    puts p.comments.class.name
    assert p.comments.kind_of?(::Set)

    p.save

    p = Product[p.id]
    assert_equal comments, p.comments
    assert_equal %Q(["Awesome!","Good product","Great."]), p.key.hget(:comments)
    assert_equal %Q(["Awesome!","Good product","Great."]), p.comments.to_s
  end
end
