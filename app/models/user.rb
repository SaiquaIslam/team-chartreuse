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
    has_many :visits



def active_for_authentication?
  super && !suspended?
end

def inactive_message
  suspended? ? :suspended : super
end


end
