require_relative "helper"
require_relative "../lib/ohm/softdelete"

class Person < Ohm::Model
  include Ohm::SoftDelete

  attribute :name
  index :name

  attribute :age
  index :age
end

test "deleted?" do
  person = Person.create

  assert !person.deleted?

  person.delete

  assert person.deleted?
end

test "all excludes deleted records" do
  person = Person.create(name: "matz")

  assert_equal person, Person.all.first

  person.delete

  assert Person.all.empty?
end

test "find does not exclude deleted records" do
  person = Person.create(name: "matz")

  assert_equal person, Person.find(name: "matz").first

  person.delete

  assert Person.find(name: "matz").include?(person)
end

test "find with many criteria doesn't exclude deleted records" do
  person = Person.create(name: "matz", age: 38)

  assert_equal person, Person.find(name: "matz", age: 38).first

  person.delete

  assert Person.find(name: "matz", age: 38).include?(person)
end

test "exists? returns true for deleted records" do
  person = Person.create(name: "matz").delete

  assert Person.exists?(person.id)
end

test "Model[n] can be used to retrieve deleted records" do
  person = Person.create(name: "matz").delete

  assert Person[person.id].deleted?
  assert_equal "matz", Person[person.id].name
end

test "restoring" do
  person = Person.create(name: "matz").delete

  assert Person.all.empty?

  person.restore

  assert Person.all.include?(person)
end
