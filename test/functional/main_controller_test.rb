require 'test_helper'

class MainControllerTest < ActionController::TestCase

  test 'Not authenticated' do
    post :create, :root_entry => {:body => 'Hello!'}
    assert_redirected_to login_path
  end

  test 'Authenticated' do
    UserSession.create(users(:vlad))
    post :create, :root_entry => {:body => 'Hello!'}, :format => :js
    assert_response :success
  end
  

end
