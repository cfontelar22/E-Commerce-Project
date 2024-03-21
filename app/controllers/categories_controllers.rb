class CategoriesController < ApplicationController
    def show
      @category = Category.find(params[:id])
      @products = @category.products
    end
  
    # If you have an index method, it should list all categories
    def index
      @categories = Category.all
    end
  end
  