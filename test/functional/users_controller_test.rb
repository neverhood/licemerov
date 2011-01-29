require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test 'Profile owner?' do
    UserSession.create(users(:vlad))
    get :show, :user_profile => users(:vlad).login
    assert_response :success # 200 ?
    assert_equal UserSession.find.record, users(:vlad) # current user = vlad ?
    assert_equal assigns(:user), users(:vlad) # @user = vlad ?
  end

  test 'Not profile owner' do
    User.create(:login => 'avi', :password => '12345', :password_confirmation => '12345',
    :email => 'avi.fogel@gmail.com')
    UserSession.create(users(:vlad))
    get :show, :user_profile => users(:avi).login
    assert_response :success # 200 ?
    assert_not_equal UserSession.find.record, users(:avi)
    assert_not_equal assigns(:user), users(:vlad)
  end

  test 'Not existing user' do
    get :show, :user_profile => 'fogel'
    assert_redirected_to root_path
    assert_equal 'User fogel not found', flash[:alert]
  end

  test 'Too short login' do
    get :show, :user_profile => 'af'
    assert_redirected_to root_path
    assert_equal nil, flash[:alert]
  end


end
