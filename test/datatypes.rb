require_relative "helper"
require_relative "../lib/ohm/datatypes"

class Product < Ohm::Model
  include Ohm::DataTypes

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
  product = Product.new(stock: "1")

  assert_equal 1, product.stock
  product.save

  product = Product[product.id]
  assert_equal 1, product.stock
end

test "Type::Time" do
  time = Time.utc(2011, 11, 22)
  product = Product.new(bought_at: time)

  assert product.bought_at.kind_of?(Time)
  product.save

  product = Product[product.id]
  assert product.bought_at.kind_of?(Time)
  assert_equal time, product.bought_at

  assert_equal "2011-11-22 00:00:00 UTC", product.get(:bought_at)
  assert_equal "2011-11-22 00:00:00 UTC", product.bought_at.to_s
end

test "Type::Date" do
  product = Product.new(date_released: Date.today)

  assert product.date_released.kind_of?(Date)

  product = Product.new(date_released: "2011-11-22")
  assert product.date_released.kind_of?(Date)

  product.save

  product = Product[product.id]
  assert_equal Date.new(2011, 11, 22), product.date_released
  assert_equal "2011-11-22", product.get(:date_released)
  assert_equal "2011-11-22", product.date_released.to_s
end

test "Type::Hash" do
  sizes = { "XS" => 1, "S" => 2, "L" => 3 }

  product = Product.new(sizes: sizes)
  assert product.sizes.kind_of?(Hash)
  product.save

  product = Product[product.id]
  assert_equal sizes, product.sizes
  assert_equal %Q[{"XS":1,"S":2,"L":3}], product.get(:sizes)
  assert_equal %Q[{"XS":1,"S":2,"L":3}], product.sizes.to_s
end

test "Type::Array" do
  stores = ["walmart", "marshalls", "jcpenny"]
  product = Product.new(stores: stores)
  assert product.stores.kind_of?(Array)

  product.save

  product = Product[product.id]
  assert_equal stores, product.stores
  assert_equal %Q(["walmart","marshalls","jcpenny"]), product.get(:stores)
  assert_equal %Q(["walmart","marshalls","jcpenny"]), product.stores.to_s
end

test "Type::Decimal" do
  product = Product.new(price: 0.001)

  # This fails if 0.001 is a float.
  x = 0
  1000.times { x += product.price }
  assert_equal 1, x

  product.save

  product = Product[product.id]
  assert_equal 0.001, product.price
  assert_equal "0.1E-2", product.get(:price)
end

test "Type::Float" do
  product = Product.new(rating: 4.5)
  assert product.rating.kind_of?(Float)

  product.save
  product = Product[product.id]
  assert_equal 4.5, product.rating
  assert_equal "4.5", product.get(:rating)
end

test "Type::Boolean" do
  product = Product.new(published: 1)
  assert_equal true, product.published

  product.save

  product = Product[product.id]
  assert_equal "true", product.get(:published)
  assert_equal true, product.published

  product.published = false
  product.save

  product = Product[product.id]
  assert_equal nil, product.get(:published)
  assert_equal false, product.published
end

test "Type::Symbol" do
  product = Product.new(state: 'available')

  assert_equal :available, product.state
  product.save

  product = Product[product.id]
  assert_equal :available, product.state
end

test "Type::Set" do
  comments = ::Set.new(["Good product", "Awesome!", "Great."])
  product = Product.new(comments: comments)
  assert product.comments.kind_of?(::Set)

  product.save

  product = Product[product.id]

  assert_equal comments, product.comments
  assert_equal %Q(["Awesome!","Good product","Great."]), product.get(:comments)
  assert_equal %Q(["Awesome!","Good product","Great."]), product.comments.to_s
end
