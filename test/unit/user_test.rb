require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'Valid user' do
    assert users(:vlad).save
  end

  test 'Wrong password confirmation' do
    assert !User.new(:login => 'vlad2', :password => '12345', :password_confirmation => '123456',
    :email => 'vlad.khomich@gmail.com').save
  end

  test 'Blank password' do
    assert !User.new(:login => 'vlad2', :password => '', :password_confirmation => '',
    :email => 'vlad.khomich@gmail.com').save
  end

  test 'Restricted login' do
    assert !User.new(:login => 'admin', :password => '12345', :password_confirmation => '12345',
    :email => 'admin@licemerov.net').save
  end

  test 'Too short login' do
    assert !User.new(:login => 'vl', :password => '12345', :password_confirmation => '12345',
    :email => 'admin@licemerov.net').save
  end

  test 'Too long login' do
    assert !User.new(:login => 'tahtistoolonglogin', :password => '12345', :password_confirmation => '12345',
    :email => 'admin@licemerov.net').save
  end

  test 'Taken login' do
    users(:vlad).save # login: vlad, email: vkhomich.vlad@gmail.com
    assert !User.new(:login => 'vlad', :email => 'admin@licemerov.net', :password => '12345',
    :password_confirmation => '12345').save, 'Saved user with duplicated login'
  end

  test 'Taken email' do
    users(:vlad).save # login: vlad, email: khomich.vlad@gmail.com
    assert !User.new(:login => 'vlad2', :email => 'khomich.vlad@gmail.com', :password => '12345',
    :password_confirmation => '12345').save
  end

end
