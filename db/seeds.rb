puts "Creating corpse flowers..."

flowers = [
  { name: "Titan Arum", description: "...", price: 2499.00, size: "large", color: "Deep Burgundy", putridity: 9, stock: 3, status: "available", image_url: "/images/flowers/1.jpg" },

  { name: "Big Stinker", description: "...", price: 4299.00, size: "large", color: "Dark Purple", putridity: 10, stock: 2, status: "available", image_url: "/images/flowers/2.jpg" },

  { name: "Purple Majesty", description: "...", price: 899.00, size: "small", color: "Royal Purple", putridity: 4, stock: 8, status: "available", image_url: "/images/flowers/3.jpg" },

  { name: "Dark Beauty", description: "...", price: 2199.00, size: "medium", color: "Deep Maroon", putridity: 6, stock: 5, status: "available", image_url: "/images/flowers/4.jpg" },

  { name: "Crimson Death", description: "...", price: 1899.00, size: "large", color: "Crimson Red", putridity: 8, stock: 7, status: "available", image_url: "/images/flowers/5.jpg" },

  { name: "Midnight Bloom", description: "...", price: 3299.00, size: "large", color: "Midnight Black", putridity: 10, stock: 1, status: "available", image_url: "/images/flowers/6.jpg" },

  { name: "Emerald Wonder", description: "...", price: 1499.00, size: "medium", color: "Emerald Green", putridity: 6, stock: 12, status: "available", image_url: "/images/flowers/7.jpg" },

  { name: "Scarlet Stench", description: "...", price: 1699.00, size: "medium", color: "Scarlet", putridity: 8, stock: 8, status: "available", image_url: "/images/flowers/8.jpg" },

  { name: "Vanilla Sky", description: "...", price: 1299.00, size: "small", color: "Cream White", putridity: 3, stock: 15, status: "available", image_url: "/images/flowers/9.jpg" },

  { name: "Sunset Orange", description: "...", price: 1999.00, size: "large", color: "Sunset Orange", putridity: 6, stock: 6, status: "available", image_url: "/images/flowers/1.jpg" },

  { name: "Phantom Grey", description: "...", price: 2199.00, size: "medium", color: "Phantom Grey", putridity: 5, stock: 5, status: "available", image_url: "/images/flowers/2.jpg" },

  { name: "Cherry Blossom", description: "...", price: 1799.00, size: "medium", color: "Cherry Pink", putridity: 4, stock: 9, status: "available", image_url: "/images/flowers/3.jpg" }
]

flowers.each do |data|
  CorpseFlower.create!(data)
  puts "✓ #{data[:name]}"
end

puts "\n✅ Created #{CorpseFlower.count} corpse flowers!"

# ===== Ensure Sajal is Admin =====
admin_email = "shovon030cse.kuet@gmail.com"

user = User.find_or_initialize_by(email: admin_email)

user.password = "password123"
user.password_confirmation = "password123"
user.role = :admin   # This makes the user an admin
user.save!

puts "✅ Admin ensured: #{admin_email} (role: #{user.role})"


puts "Seeding users..."
user1 = User.create!(email: "alice@example.com",  password: "password123")
user2 = User.create!(email: "bob@example.com",    password: "password123")
user3 = User.create!(email: "charlie@example.com", password: "password123")

puts "Seeding hunt registrations..."

hunts = [
  {
    nickname: "Midtown Titan",
    location_description: "Overton Park, Memphis TN",
    latitude: 35.1501,
    longitude: -89.9940,
    instructions: "Park near the main pavilion and walk 5 minutes north.",
    user: user1,
    photo_filename: "1.png"
  },
  {
    nickname: "East Memphis Stinker",
    location_description: "Shelby Farms Park - Visitor Center",
    latitude: 35.1392,
    longitude: -89.8482,
    instructions: "Follow the Yellow Trail to the botanical area.",
    user: user2,
    photo_filename: "2.png"
  },
  {
    nickname: "Downtown Bloom",
    location_description: "Beale Street Landing",
    latitude: 35.1380,
    longitude: -90.0586,
    instructions: "Check near the riverside walkway.",
    user: user3,
    photo_filename: "3.png"
  }
]

hunts.each do |attrs|
  filename = attrs.delete(:photo_filename)
  record = HuntRegistration.create!(attrs)

  # Attach a placeholder photo (use any jpeg/png you add)
  photo_path = Rails.root.join("public", "images", "hunt_flowers", filename)

  if File.exist?(photo_path)
    record.photo.attach(
      io: File.open(photo_path),
      filename: filename,
      content_type: "image/png"
    )
  end

  puts "Created #{record.nickname}"
end

puts "Seeding completed!"
