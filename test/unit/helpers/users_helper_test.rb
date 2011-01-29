require 'test_helper'

class UsersHelperTest < ActionView::TestCase

  def valid_user
    User.new(:login => 'vlad2', :password => '12345', :password_confirmation => '12345',
    :email => 'vlad.khomich@gmail.com')
  end
end
