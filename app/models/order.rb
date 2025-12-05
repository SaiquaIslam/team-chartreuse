# == Schema Information
#
# Table name: orders
#
#  id               :bigint           not null, primary key
#  shipping_address :string
#  shipping_city    :string
#  shipping_name    :string
#  shipping_phone   :string
#  shipping_state   :string
#  shipping_zip     :string
#  status           :string
#  total_cents      :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_orders_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :corpse_flowers, through: :order_items

  with_options on: :shipping do
    validates :shipping_name,    presence: true
    validates :shipping_address, presence: true
    validates :shipping_city,    presence: true
    validates :shipping_state,   presence: true
    validates :shipping_zip,     presence: true
    validates :shipping_phone,   presence: true

    validates :shipping_zip, format: {
      with: /\A\d{5}(-\d{4})?\z/,
      message: "must be a valid ZIP code (e.g. 12345 or 12345-6789)"
    }

    validates :shipping_phone, format: {
      with: /\A\+?[0-9\-\s]{7,}\z/,
      message: "must be a valid phone number"
    }
  end

  # ---------------------------
  # Payment validations (US11)
  # ---------------------------
  with_options on: :payment do
    validates :card_number,        presence: true, format: {
      with: /\A\d{16}\z/,
      message: "must be 16 digits"
    }
    validates :card_expiration_month, presence: true, inclusion: { in: 1..12 }
    validates :card_expiration_year,  presence: true
    validates :card_cvv,              presence: true, format: {
      with: /\A\d{3,4}\z/,
      message: "must be 3 or 4 digits"
    }
    validates :billing_zip, presence: true, format: {
      with: /\A\d{5}(-\d{4})?\z/,
      message: "must be a valid ZIP code"
    }
  end
end