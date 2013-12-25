require_relative "helper"
require_relative "../lib/ohm/callbacks"

class Post < Ohm::Model
  include Ohm::Callbacks

  attribute :body

  def did?(action)
    !!instance_variable_get("@#{ action }")
  end

  def count(action)
    instance_variable_get("@#{ action }")
  end

protected

  def before_create()   incr(:do_before_create)   end
  def after_create()    incr(:do_after_create)    end
  def before_save()     incr(:do_before_save)     end
  def after_save()      incr(:do_after_save)      end
  def before_update()   incr(:do_before_update)   end
  def after_update()    incr(:do_after_update)    end
  def before_delete()   incr(:do_before_delete)   end
  def after_delete()    incr(:do_after_delete)    end

  def incr(action)
    val = instance_variable_get("@#{ action }")
    val ||= 0
    val += 1

    instance_variable_set("@#{ action }", val)
  end
end

test "create invokes all callbacks (except update)" do
  post = Post.create(body: "The Body")

  assert post.did?(:do_before_create)
  assert post.did?(:do_after_create)
  assert post.did?(:do_before_save)
  assert post.did?(:do_after_save)
  assert !post.did?(:do_before_update)
  assert !post.did?(:do_after_update)
end

test "create only invokes save / create once" do
  post = Post.create(body: "The Body")

  assert_equal 1, post.count(:do_before_create)
  assert_equal 1, post.count(:do_after_create)
  assert_equal 1, post.count(:do_before_save)
  assert_equal 1, post.count(:do_after_save)
end

test "ensure create / save callbacks are only called once" do
  post = Post.new(body: "The Body")
  post.save

  assert_equal 1, post.count(:do_before_create)
  assert_equal 1, post.count(:do_after_create)
  assert_equal 1, post.count(:do_before_save)
  assert_equal 1, post.count(:do_after_save)
end

test "save of existing record executes save and update callbacks" do
  post = Post.create(body: "The Body")
  post = Post[post.id]
  post.save

  assert ! post.did?(:do_before_create)
  assert ! post.did?(:do_after_create)

  assert post.did?(:do_before_save)
  assert post.did?(:do_after_save)
  assert post.did?(:do_before_update)
  assert post.did?(:do_after_update)

  assert_equal 1, post.count(:do_before_save)
  assert_equal 1, post.count(:do_after_save)
  assert_equal 1, post.count(:do_before_update)
  assert_equal 1, post.count(:do_after_update)
end

test "save of existing record (using #update)" do
  post = Post.create(body: "The Body")
  post = Post[post.id]
  post.update(body: "New Body")

  assert ! post.did?(:do_before_create)
  assert ! post.did?(:do_after_create)

  assert post.did?(:do_before_save)
  assert post.did?(:do_after_save)
  assert post.did?(:do_before_update)
  assert post.did?(:do_after_update)

  assert_equal 1, post.count(:do_before_save)
  assert_equal 1, post.count(:do_after_save)
  assert_equal 1, post.count(:do_before_update)
  assert_equal 1, post.count(:do_after_update)
end

test "on delete" do
  post = Post.create(body: "The Body")
  post = Post[post.id]
  post.delete

  assert_equal 1, post.count(:do_before_delete)
  assert_equal 1, post.count(:do_after_delete)

  assert ! post.did?(:do_before_create)
  assert ! post.did?(:do_after_create)
  assert ! post.did?(:do_before_save)
  assert ! post.did?(:do_after_save)
  assert ! post.did?(:do_before_update)
  assert ! post.did?(:do_after_update)
end
