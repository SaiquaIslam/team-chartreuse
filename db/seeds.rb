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
