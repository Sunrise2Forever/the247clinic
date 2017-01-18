require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title,         "24-7 Online Clinic"
    assert_equal full_title("Help"), "Help | 24-7 Online Clinic"
  end
end