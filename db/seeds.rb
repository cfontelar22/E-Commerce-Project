require 'httparty'


# Destroy existing data
Category.destroy_all
Product.destroy_all

# Create some categories
categories = ['Single Origin', 'Blended', 'Espresso']
categories.each do |category_name|
  Category.create!(name: category_name)
end
puts "Created #{Category.count} categories."


# Fetch the data from the API
response = HTTParty.get('https://fake-coffee-api.vercel.app/api/')
if response.success?
  products_data = response.parsed_response

  # Seed the products
  products_data.each do |product_data|
    category = Category.find_or_create_by(name: product_data['flavor_profile'] || 'General')

    product = Product.create(
      name: product_data['name'],
      description: product_data['description'],
      price: product_data['price'],
      quantity: product_data['inventoryCount'] 
      category: category,
      flavor_profile: product_data['flavor_profile'],
      grind_option: product_data['grind_option'],
      roast_level: product_data['roast_level'],
      region: product_data['region'],
      
      # You would handle image attachment here
      # For example, using ActiveStorage:
      # image: Rails.root.join("path/to/downloaded/image.jpg").open
    )

    if product.persisted?
      puts "Seeded product: #{product.name}"
      # If the API provides a direct URL to an image:
      # downloaded_image = URI.open(product_data['image_url'])
      # product.image.attach(io: downloaded_image, filename: 'product_image.jpg')
    else
      puts "Failed to create product: #{product.name}"
      puts product.errors.full_messages
    end
  end

  puts "Seeded #{Product.count} products."
else
  puts "Failed to retrieve data from API. Status code: #{response.code}"
end
