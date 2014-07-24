require_relative "helper"
require "byebug"
require_relative "../lib/ohm/dirty"

class Post < Ohm::Model
  include Ohm::Dirty

  attribute :body
end

test "changes change" do
  post = Post.create(body: "The Body")
  post.body = "new value"

  assert post.changes == {body: ["The Body", "new value"]}
end

test "changes no change" do
  post = Post.create(body: "The Body")

  assert post.changes == {}
end

test "changed?" do
  post = Post.create(body: "The Body")
  post.body = "new value"

  assert post.changed? == true
end

test "changed" do
  post = Post.create(body: "The Body")
  post.body = "new value"

  assert post.changed == [:body]
end

test "changed_attributes" do
  post = Post.create(body: "The Body")
  post.body = "new value"

  assert post.changed_attributes == {:body => "The Body"}
end

