# frozen_string_literal: true

if Rails.env.development?
  CorpseFlower.destroy_all
end

puts "Creating corpse flowers..."

flowers = [
  { name: "Titan Arum", description: "The Amorphophallus titanum, known as the Titan Arum or corpse flower, is native to the rainforests of western Sumatra. It can grow up to 10 feet tall and blooms for only 24-48 hours every 7-10 years.", price: 2499.00, size: "Medium 6ft", color: "Deep Burgundy", putridity: "Strong", stock: 3, status: "available", image_url: "/images/flowers/1.jpg" },
  
  { name: "Big Stinker", description: "This large Amorphophallus specimen is known for producing one of the most overwhelming scents. Indonesian collectors call it 'bunga bangkai raksasa'.", price: 4299.00, size: "Large 9ft", color: "Dark Purple", putridity: "Overwhelming", stock: 2, status: "available", image_url: "/images/flowers/2.jpg" },
  
  { name: "Purple Majesty", description: "A stunning purple variant of Amorphophallus paeoniifolius. This smaller species is more manageable for home cultivation.", price: 899.00, size: "Small 3ft", color: "Royal Purple", putridity: "Mild", stock: 8, status: "available", image_url: "/images/flowers/3.jpg" },
  
  { name: "Dark Beauty", description: "Amorphophallus konjac 'Dark Beauty' is a medium-sized species perfect for serious collectors. The dark red to maroon spathe creates dramatic visual impact.", price: 2199.00, size: "Medium 7ft", color: "Deep Maroon", putridity: "Moderate", stock: 5, status: "available", image_url: "/images/flowers/4.jpg" },
  
  { name: "Crimson Death", description: "Spectacular crimson Amorphophallus bulbifer specimen. This Southeast Asian native features brilliant red spathe coloration.", price: 1899.00, size: "Large 8ft", color: "Crimson Red", putridity: "Strong", stock: 7, status: "available", image_url: "/images/flowers/5.jpg" },
  
  { name: "Midnight Bloom", description: "Extremely rare Amorphophallus titanum variant with nearly black spathe coloration. Only a handful exist worldwide.", price: 3299.00, size: "Extra Large 10ft", color: "Midnight Black", putridity: "Overwhelming", stock: 1, status: "available", image_url: "/images/flowers/6.jpg" },
  
  { name: "Emerald Wonder", description: "Unique green-spatheed Amorphophallus gigas from Thailand. Unlike typical corpse flowers, this variety maintains bright emerald green coloration.", price: 1499.00, size: "Medium 5ft", color: "Emerald Green", putridity: "Moderate", stock: 12, status: "available", image_url: "/images/flowers/7.jpg" },
  
  { name: "Scarlet Stench", description: "Amorphophallus variabilis 'Scarlet' produces one of the most pungent odors in the genus. Collectors prize it for the brilliant scarlet spathe.", price: 1699.00, size: "Medium 6ft", color: "Scarlet", putridity: "Strong", stock: 8, status: "available", image_url: "/images/flowers/8.jpg" },
  
  { name: "Vanilla Sky", description: "Extremely rare albino Amorphophallus paeoniifolius. This genetic variant produces cream to pale yellow spathes.", price: 1299.00, size: "Small 4ft", color: "Cream White", putridity: "Mild", stock: 15, status: "available", image_url: "/images/flowers/9.jpg" },
  
  { name: "Sunset Orange", description: "Amorphophallus titanum 'Sunset' is a recently discovered color variant from central Sumatra with beautiful gradient coloring.", price: 1999.00, size: "Large 8ft", color: "Sunset Orange", putridity: "Moderate", stock: 6, status: "available", image_url: "/images/flowers/1.jpg" },
  
  { name: "Phantom Grey", description: "Mysterious grey Amorphophallus atroviridis from Myanmar. The grey coloration comes from a fine covering of silvery trichomes.", price: 2199.00, size: "Medium 6ft", color: "Phantom Grey", putridity: "Moderate", stock: 5, status: "available", image_url: "/images/flowers/2.jpg" },
  
  { name: "Cherry Blossom", description: "Delicate pink Amorphophallus bulbifer 'Sakura' cultivar bred in Japan. Don't let the beautiful coloring fool you - full-strength carrion scent.", price: 1799.00, size: "Medium 5ft", color: "Cherry Pink", putridity: "Moderate", stock: 9, status: "available", image_url: "/images/flowers/3.jpg" }
]

flowers.each do |data|
  CorpseFlower.create!(data)
  puts "✓ #{data[:name]}"
end

puts "\n✅ Created #{CorpseFlower.count} corpse flowers!"