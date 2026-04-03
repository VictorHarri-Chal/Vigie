require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include Warden::Test::Helpers
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  teardown do
    Warden.test_reset!
  end

  private

  def sign_in_as(user)
    login_as(user, scope: :user)
  end
end
