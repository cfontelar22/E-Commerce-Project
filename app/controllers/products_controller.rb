class ProductsController < ApplicationController
  def index
    # Fetch all products or by category
    if params[:category].present?
      @category = Category.find_by(name: params[:category])
      @products = Product.where(category: @category).page(params[:page]).per(20) # Specify 20 or any number of products per page
    else
      @products = Product.all.page(params[:page]).per(20) # Specify 20 or any number of products per page
    end
  end

  def show
    @product = Product.find(params[:id])
  end
end