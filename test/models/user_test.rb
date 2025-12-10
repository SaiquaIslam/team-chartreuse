# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("customer")
#  suspended              :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
require "test_helper"


class UserTest < ActiveSupport::TestCase

  ##### Sajal's scopes #####
  def setup
    @admin = users(:admin)
    @regular = users(:regular)
    @suspended = users(:suspended)
  end

  test "admin should have role admin" do
    assert_equal "admin", @admin.role
  end

  test "regular user should not be admin" do
    refute_equal "admin", @regular.role
  end

  test "suspended flag works" do
    assert @suspended.suspended
    refute @regular.suspended
  end

  test "suspended user not active for authentication" do
    # This assumes you implemented in User model:
    # def active_for_authentication?
    #   super && !suspended?
    # end
    refute @suspended.active_for_authentication?
    assert @regular.active_for_authentication?
  end

##### Sajal's scopes #####

end


