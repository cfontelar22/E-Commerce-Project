require 'httparty'
2
# Fetch the data from the API
response = HTTParty.get('https://fake-coffee-api.vercel.app/api/')
if response.success?
  products_data = response.parsed_response

  # Seed the products
  products_data.each do |product_data|
    product = Product.create(
      name: product_data['name'], # Adjust this if the JSON key for the name is different
      description: product_data['description'], # Adjust this if the JSON key for the description is different
      price: product_data['price'], # Adjust this if the JSON key for the price is different
      quantity: product_data['inventoryCount'] # Adjust this if the JSON key for quantity is different
     
    )
    puts "Seeded product: #{product.name}" if product.persisted?
  end

  puts "Seeded #{Product.count} products."
else
  puts "Failed to retrieve data from API. Status code: #{response.code}"
end
