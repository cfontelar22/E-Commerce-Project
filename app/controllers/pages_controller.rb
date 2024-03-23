class PagesController < ApplicationController
  def home
    @featured_products = Product.order(created_at: :desc).limit(6)
    @all_products = Product.page(params[:page]).per(10)
  end

  
  def about
    @about = About.first
  end
  
  def contact
    @contact = Contact.first
  end
end