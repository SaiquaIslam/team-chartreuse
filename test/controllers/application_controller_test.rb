# frozen_string_literal: true

require "test_helper"

class ApplicationControllerTest < ActiveSupport::TestCase
  test "after_sign_in_path_for returns root_path" do
    controller = ApplicationController.new

    # Stub root_path to avoid depending on actual routes
    controller.define_singleton_method(:root_path) { "/" }

    result = controller.send(:after_sign_in_path_for, :user)
    assert_equal "/", result
  end

  test "after_sign_out_path_for returns root_path" do
    controller = ApplicationController.new

    controller.define_singleton_method(:root_path) { "/" }

    result = controller.send(:after_sign_out_path_for, :user)
    assert_equal "/", result
  end
end
