require 'test_helper'

class RootEntryTest < ActiveSupport::TestCase

  test 'Too short body' do
    assert !RootEntry.new(:body => 'F').save
  end

  test 'Too long body' do
    UserSession.create(users(:vlad))
    assert !RootEntry.new(:body => 'Hello!' * 50).save
  end

end
