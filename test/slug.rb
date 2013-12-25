require_relative "../lib/ohm/slug"
require_relative "helper"

class Article < Ohm::Model
  include Ohm::Slug

  attribute :title

  def to_s
    title
  end
end

test "to_param" do
  article = Article.create(title: "A very Unique and Interesting String?'")

  assert_equal '1-a-very-unique-and-interesting-string', article.to_param
end

test "finding" do
  article = Article.create(title: "A very Unique and Interesting String?'")

  assert_equal 1, Article[article.to_param].id
end
