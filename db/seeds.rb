require 'httparty'
require 'faker'
require 'open-uri'

# Destroy existing data
Product.destroy_all
Category.destroy_all

# Create categories
unique_categories = ['Single Origin', 'Blended', 'Espresso', 'Light Roast','Medium Roast' 'Dark Roast']
unique_categories.each do |category_name|
  Category.find_or_create_by!(name: category_name)
end

# Ensure there is a 'General' category
general_category = Category.find_or_create_by!(name: 'General')

puts "Created #{Category.count} categories."

# Fetch the data from the API
response = HTTParty.get('https://fake-coffee-api.vercel.app/api/')
if response.success?
  products_data = response.parsed_response * 5 

  products_data.each_with_index do |product_data, index|
    # Find the specific category or use 'General'
    category_name = product_data['flavor_profile'].first
    category = Category.find_by(name: category_name) || general_category

    # Create the product with the information from the API
    product = Product.create(
      name: product_data['name'],
      description: product_data['description'],
      price: product_data['price'].to_f + Faker::Commerce.price(range: 0..0.99),
      quantity: product_data['inventoryCount'],
      category: category,
      region: product_data['region'], 
      weight: product_data['weight'],
      roast_level: product_data['roast_level'],
      flavor_profile: product_data['flavor_profile'].join(', '),
      grind_option: product_data['grind_option'].join(', ') 
    )

    # Attach the image if the product was saved and an image URL is available
    if product.persisted? && product_data['image_url'].present?
      begin
        # Open the image URL and attach it to the product
        downloaded_image = URI.open(product_data['image_url'])
        product.image.attach(io: downloaded_image, filename: "product_#{product.id}.jpg")
        puts "Image attached to product: #{product.name}"
      rescue OpenURI::HTTPError => e
        puts "Failed to download or attach image for product: #{product.name}. Error: #{e.message}"
      end
    end
  end

  puts "Seeded #{Product.count} products."
else
  puts "Failed to retrieve data from API. Status code: #{response.code}"
end
