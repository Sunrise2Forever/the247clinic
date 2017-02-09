require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:foo)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name:  "akdf",
                                    email: "foo@invalid",
                                    mspnum: 1654212,
                                    password:              "foo",
                                    password_confirmation: "bar" }
    assert_template 'users/edit'
  end
  
 test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    mspnum = 5433321
    patch user_path(@user), user: { name:  name,
                                    email: email,
                                    mspnum: mspnum,
                                    password:              "",
                                    password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
    assert_equal mspnum, @user.mspnum
  end  
end
