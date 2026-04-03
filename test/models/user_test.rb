require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "is valid with email and password" do
    user = User.new(email: "new@example.com", password: "password123")
    assert user.valid?
  end

  test "is invalid without email" do
    user = User.new(password: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "is invalid with malformed email" do
    user = User.new(email: "notanemail", password: "password123")
    assert_not user.valid?
    assert user.errors[:email].any?
  end

  test "is invalid with duplicate email" do
    user = User.new(email: users(:one).email, password: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "is invalid without password on create" do
    user = User.new(email: "new@example.com")
    assert_not user.valid?
    assert user.errors[:password].any?
  end
end
