require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:toto)     # Here users corresponds to the fixture filename users.yml
  end
  
  
  # TEST FOR VALID INFORMATION
  # We need a test to capture the sequence below
  # 1. Visit the login path.
  # 2. Post valid information to the sessions path.
  # 3. Verify that the login link disappears.
  # 4. Verify that a logout link appears
  # 5. Verify that a profile link appears.
  
  test "login with valid information" do
    get login_path
    post login_path, session: {email: @user.email, password: "password"}
    assert_redirected_to @user  # To check the right redirect target
    follow_redirect!            # To actually visit the target page
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0     # There must be zero login path links on the page
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
  
  # TEST FOR INVALID INFORMATION
  # We need a test to capture the sequence below
  # 1. Visit the login path.
  # 2. Verify that the new sessions form renders properly.
  # 3. Post to the sessions path with an invalid params hash.
  # 4. Verify that the new sessions form gets re-rendered and that a flash message appears.
  # 5. Visit another page (such as the Home page).
  # 6. Verify that the flash message doesn’t appear on the new page.
  
  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: {email: "", password: "" }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
  
  test "login with valid information followed by logout" do
    get login_path
    post login_path, session: {email: @user.email, password: "password"}
    assert is_logged_in?
    assert_redirected_to @user  # To check the right redirect target
    follow_redirect!            # To actually visit the target page
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0     # There must be zero login path links on the page
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # Simulate a user clicking logout in a second window
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
  
  # Inside a test, you can access instance variables (i.e @user)defined in the controller using 
  # a special test method called assigns. Ex: assigns(:user)
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end
  
  test "login without remembering" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end
end
