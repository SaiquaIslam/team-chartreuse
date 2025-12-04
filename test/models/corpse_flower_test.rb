# == Schema Information
#
# Table name: corpse_flowers
#
#  id          :bigint           not null, primary key
#  color       :string
#  description :text
#  image_url   :string
#  name        :string           not null
#  price       :decimal(10, 2)   not null
#  putridity   :integer
#  size        :string
#  status      :string           default("available")
#  stock       :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_corpse_flowers_on_name    (name)
#  index_corpse_flowers_on_status  (status)
#
