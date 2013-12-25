require_relative "helper"
require "override"
require_relative "../lib/ohm/timestamps"

class Person < Ohm::Model
  include Ohm::Timestamps
end

NOW = Time.utc(2010, 5, 12)

include Override

prepare do
  override(Time, now: NOW)
end

test "a new? record" do
  assert_equal nil, Person.new.created_at
  assert_equal nil, Person.new.updated_at
end

test "on create" do
  person = Person.create
  person = Person[person.id]

  assert_equal NOW, person.created_at
  assert_equal NOW, person.updated_at
end

test "on update" do
  person = Person.create

  override(Time, now: Time.utc(2010, 5, 13))
  person.save

  person = Person[person.id]

  assert_equal NOW, person.created_at
  assert_equal Time.utc(2010, 5, 13), person.updated_at
end
