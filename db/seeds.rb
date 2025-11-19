# ========================================
# DEVELOPMENT/TESTING SEEDS ONLY
# ========================================
# In production, flowers will be added by admins through
# the admin panel (US17 - implemented by Sajal)
# This seed file is for development and testing purposes
# ========================================

# Clear existing data
puts "Clearing existing corpse flowers..."
CorpseFlower.destroy_all

# Create sample corpse flowers
puts "Creating sample corpse flowers..."

flowers_data = [
  {
    name: "Titan Arum Supreme",
    description: "The largest and most magnificent corpse flower in our collection. Known for its incredible height and powerful odor that can fill an entire room. This specimen blooms rarely, making it a true collector's item.",
    price: 1999.99,
    size: "large",
    putridity: 10,
    color: "deep burgundy",
    stock: 3
  },
  {
    name: "Midnight Rotblossom",
    description: "A striking dark variety with deep purple petals and an intense fragrance. Perfect for those who appreciate the darker side of botanical beauty. Requires minimal maintenance.",
    price: 899.99,
    size: "medium",
    putridity: 8,
    color: "dark purple",
    stock: 7
  },
  {
    name: "Putrid Princess",
    description: "A smaller, more manageable variety ideal for beginners. Don't let the size fool you - this flower packs a powerful aromatic punch that belies its compact form.",
    price: 499.99,
    size: "small",
    putridity: 6,
    color: "maroon",
    stock: 12
  },
  {
    name: "Crimson Stench",
    description: "Features brilliant crimson coloring with an exceptionally potent odor. This variety is particularly hardy and blooms more frequently than most corpse flowers.",
    price: 1299.99,
    size: "large",
    putridity: 9,
    color: "crimson",
    stock: 5
  },
  {
    name: "Emerald Decay",
    description: "Rare green-tinged variety with moderate putridity. An unusual specimen that combines beauty with the characteristic corpse flower scent. Highly sought after by collectors.",
    price: 1599.99,
    size: "medium",
    putridity: 7,
    color: "green",
    stock: 2
  },
  {
    name: "Compact Carrion",
    description: "Perfect for apartment dwellers who want to experience the unique charm of corpse flowers without overwhelming their space. Small but mighty in aroma.",
    price: 399.99,
    size: "small",
    putridity: 5,
    color: "burgundy",
    stock: 15
  },
  {
    name: "Violet Vulgaris",
    description: "A stunning violet specimen with medium putridity levels. This variety is known for its vibrant color and relatively pleasant appearance despite its unmistakable scent.",
    price: 799.99,
    size: "medium",
    putridity: 7,
    color: "violet",
    stock: 8
  },
  {
    name: "Obsidian Odor",
    description: "Nearly black petals create a dramatic appearance. This rare variety is prized for its aesthetic appeal and moderate scent level, making it suitable for display.",
    price: 2499.99,
    size: "large",
    putridity: 8,
    color: "black",
    stock: 1
  },
  {
    name: "Petite Putrescence",
    description: "The smallest in our collection but don't underestimate its impact. Ideal for those new to corpse flower cultivation or with limited space.",
    price: 299.99,
    size: "small",
    putridity: 4,
    color: "red",
    stock: 20
  },
  {
    name: "Sunset Stinker",
    description: "Beautiful orange and red gradient coloring reminiscent of a sunset. Medium sized with a powerful but not overwhelming scent profile.",
    price: 999.99,
    size: "medium",
    putridity: 8,
    color: "orange",
    stock: 6
  },
  {
    name: "Royal Rot",
    description: "A majestic purple variety that lives up to its regal name. Large specimen with maximum putridity for the true corpse flower enthusiast.",
    price: 1899.99,
    size: "large",
    putridity: 10,
    color: "royal purple",
    stock: 4
  },
  {
    name: "Amber Aroma",
    description: "Unique amber coloring with a moderate scent. This variety is less common and highly valued by collectors for its unusual hue.",
    price: 1199.99,
    size: "medium",
    putridity: 6,
    color: "amber",
    stock: 5
  },
  {
    name: "Sold Out Special",
    description: "This was our most popular variety but is currently unavailable. A medium-sized beauty with perfect balance of size and scent.",
    price: 899.99,
    size: "medium",
    putridity: 7,
    color: "burgundy",
    stock: 0
  }
]

flowers_data.each do |flower_data|
  flower = CorpseFlower.create!(flower_data)
  puts "Created: #{flower.name} - #{flower.formatted_price}"
end

puts "\n✅ Successfully created #{CorpseFlower.count} corpse flowers!"
puts "🌸 Flowers in stock: #{CorpseFlower.where('stock > 0').count}"
puts "❌ Flowers out of stock: #{CorpseFlower.where(stock: 0).count}"