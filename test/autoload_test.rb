# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

test "autoloading of all libraries" do
  assert_nothing_raised NameError, LoadError do
    Ohm::ActiveModelExtension
    Ohm::Boundaries
    Ohm::Timestamping
    Ohm::WebValidations
    Ohm::NumberValidations
    Ohm::Typecast
    Ohm::Locking
    Ohm::ExtraValidations
    Ohm::DateValidations
    Ohm::FulltextSearching
    Ohm::Slug
    Ohm::Looseref
    Ohm::Struct
  end
end