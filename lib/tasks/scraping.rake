namespace :scrape do
    desc "Scrape products and categories from a third-party website"
    task products: :environment do
      require 'nokogiri'
      require 'httparty'
  
      def scraper
        url = "http://example.com/products" 
        unparsed_page = HTTParty.get(url)
        parsed_page = Nokogiri::HTML(unparsed_page.body)
        products = parsed_page.css('div.product') # CSS selector for products
  
        products.each do |product|
          name = product.css('h2').text # CSS selector for product name
          price = product.css('.price').text # CSS selector for product price
          category_name = product.css('.category').text # CSS selector for category
  
          # Use ActiveRecord to save the data in your database
          category = Category.find_or_create_by(name: category_name.strip)
          Product.create(
            name: name.strip,
            price: price.strip,
            category_id: category.id
          )
        end
      end
  
      scraper # call the method to start scraping
    end
  end
  