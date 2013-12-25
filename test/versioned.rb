require_relative "helper"
require_relative "../lib/ohm/versioned"

class Article < Ohm::Model
  include Ohm::Versioned

  attribute :title
  attribute :content
end

test do
  a1 = Article.create(title: "Foo Bar", content: "Lorem ipsum")
  a2 = Article[a1.id]

  a1.update({})

  expected = { title: "Bar Baz", _version: "1", content: "Lorem ipsum" }

  begin
    a2.update(title: "Bar Baz")
  rescue Ohm::VersionConflict => ex
  end

  assert_equal expected, ex.attributes
end
