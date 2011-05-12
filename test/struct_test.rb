# encoding: UTF-8

require File.expand_path("./helper", File.dirname(__FILE__))

Contact = Struct.new(:phone, :email)

class User < Ohm::Model
  include Ohm::Struct
  struct :contact, Contact
end

user = User.create()
user.contact = Contact.new("1234", "bob@wherever.blah")

test "read struct" do
  assert Contact.new("1234", "bob@wherever.blah") == user.contact
end

test "read struct data" do
  assert user.contact_Contact_phone == user.contact.phone
  assert user.contact_Contact_email == user.contact.email
end

test "attribute writers" do
  user.contact_Contact_phone = "5678"
  assert Contact.new("5678", "bob@wherever.blah") == user.contact
  user.contact_Contact_email = "bob@newemail.fneh"
  assert Contact.new("5678", "bob@newemail.fneh") == user.contact
end
