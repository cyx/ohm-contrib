# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

class ParentClass < Ohm::Model
end

class SubClass < ParentClass
  attribute :insubonly
end

class Person < Ohm::Model
  include Ohm::Looseref
  looseref :testref, ParentClass
end

person = Person.create

test "assign ParentClass instance" do
  person.testref = ParentClass.create
  assert ParentClass == person.testref.class
  assert ParentClass.to_s == person.testref_klass
  assert_raise NoMethodError do
    person.testref.insubonly
  end
end

test "assign SubClass instance" do
  person.testref = SubClass.create(:insubonly => "test value")
  assert SubClass == person.testref.class
  assert "test value" == person.testref.insubonly
end

