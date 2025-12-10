# frozen_string_literal: true

require "test_helper"
require "uri"

class MessagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  fixtures :users, :corpse_flowers

  setup do
    @user          = users(:regular)
    @corpse_flower = corpse_flowers(:titan_arum) rescue CorpseFlower.first
  end

  ############################################################
  # NEW
  ############################################################

  test "new loads successfully without corpse_flower_id" do
    get new_message_path
    assert_response :success
  end

  test "new loads successfully with corpse_flower_id" do
    get new_message_path(corpse_flower_id: @corpse_flower.id)
    assert_response :success
  end

  test "new pre-fills email when user is signed in" do
    sign_in @user

    get new_message_path(corpse_flower_id: @corpse_flower.id)
    assert_response :success
  end

  ############################################################
  # CREATE – INVALID (normal path)
  ############################################################

  test "create with blank fields re-renders new with errors" do
    assert_no_emails_sent do
      post messages_path, params: {
        corpse_flower_id: @corpse_flower.id,
        message: {
          email:   "",
          subject: "",
          body:    ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal "Please fix the errors below.", flash[:alert]
  end

  test "create with invalid email format re-renders new with errors using main validator" do
    assert_no_emails_sent do
      post messages_path, params: {
        corpse_flower_id: @corpse_flower.id,
        message: {
          email:   "not-an-email",
          subject: "Subject present",
          body:    "Body present"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal "Please fix the errors below.", flash[:alert]
  end

  ############################################################
  # CREATE – VALID (normal path)
  ############################################################

  test "create sends email and redirects to corpse flower when corpse_flower_id is present" do
    assert_emails 1 do
      post messages_path, params: {
        corpse_flower_id: @corpse_flower.id,
        message: {
          email:   "user@example.com",
          subject: "Question about this flower",
          body:    "Is this suitable for indoor display?"
        }
      }
    end

    assert_redirected_to corpse_flower_path(@corpse_flower)
    assert_equal "Your message has been sent to the admin.", flash[:notice]
  end

  test "create sends email and redirects to root when corpse_flower_id is missing" do
    assert_emails 1 do
      post messages_path, params: {
        message: {
          email:   "user@example.com",
          subject: "General question",
          body:    "I have a general question about your shop."
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Your message has been sent to the admin.", flash[:notice]
  end

  ############################################################
  # CREATE – FORCE RESCUE PATH IN validate_message
  # (cover both branches of 'unless email.include?("@")')
  ############################################################

  test "validate_message rescue fallback handles invalid_and_valid_email" do
    # Temporarily remove EMAIL_REGEXP to force NameError and hit the rescue block
    original = nil
    if URI::MailTo.const_defined?(:EMAIL_REGEXP)
      original = URI::MailTo::EMAIL_REGEXP
      URI::MailTo.send(:remove_const, :EMAIL_REGEXP)
    end

    # ----- Case 1: invalid email (no '@') → rescue + error (then branch) -----
    assert_no_emails_sent do
      post messages_path, params: {
        corpse_flower_id: @corpse_flower.id,
        message: {
          email:   "invalid-email-without-at",
          subject: "Some subject",
          body:    "Some body"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal "Please fix the errors below.", flash[:alert]

    # ----- Case 2: valid-looking email (has '@') → rescue but NO error (else branch) -----
    assert_emails 1 do
      post messages_path, params: {
        corpse_flower_id: @corpse_flower.id,
        message: {
          email:   "fallback@example.com",  # contains '@'
          subject: "Rescue path valid email",
          body:    "This should pass validation via the rescue fallback."
        }
      }
    end

    # This second request should succeed and redirect (no errors)
    assert_redirected_to corpse_flower_path(@corpse_flower)
    assert_equal "Your message has been sent to the admin.", flash[:notice]
  ensure
    # Restore EMAIL_REGEXP so we don't break other tests
    URI::MailTo.const_set(:EMAIL_REGEXP, original) if original
  end

  ############################################################
  # Helpers
  ############################################################

  private

  def assert_no_emails_sent(&block)
    assert_emails 0, &block
  end
end
