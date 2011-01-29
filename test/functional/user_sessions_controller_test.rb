require 'test_helper'


class UserSessionsControllerTest < ActionController::TestCase

  # Replace this with your real tests.

  test 'Login page' do
    get :new
    assert_response :success
  end

  test 'Login even though already authenticated' do
    UserSession.create(users(:vlad))
    get :new
    assert_redirected_to user_profile_path(:user_profile => users(:vlad).login) #user_profile_path(users(:vlad))
  end

  test 'Logout' do
    UserSession.create(users(:vlad))
    get :destroy
    assert_redirected_to login_path
  end


end
