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
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

    enum role: { customer: 0, admin: 1 }
  has_many :hunt_registrations, dependent: :destroy
  has_many :reviews, dependent: :destroy

    # cart association (Tanvir :PR3)
    has_one :cart, dependent: :destroy

    has_many :orders, dependent: :nullify
  def display_name
    email.to_s.split("@").first
  end

  # Has this user ever purchased this specific corpse flower?
  def purchased_corpse_flower?(corpse_flower)
    Order.joins(:order_items)
         .where(
           user_id: id,
           order_items: { corpse_flower_id: corpse_flower.id }
         )
         .exists?
  end  

end
