class ProductsController < ApplicationController
  def index
  # Start with all products
  @products = Product.all

    # Initialize the Ransack search object
  @search = Product.ransack(params[:q])

  # Get the results from the Ransack search
  @products = @search.result(distinct: true)

  # Filter by category if provided
  if params[:category].present?
      @category = Category.find_by(name: params[:category])
      @products = @products.where(category: @category)
  end

  # Filter products by keyword
  if params[:keyword].present?
      @products = @products.where('name LIKE ? OR description LIKE ?', "%#{params[:keyword]}%", "%#{params[:keyword]}%")
  end

  # Filter by on_sale, newly_added, or recently_updated if provided
  @products = @products.on_sale if params[:on_sale].present? && params[:on_sale] == 'true'
  @products = @products.newly_added if params[:new].present? && params[:new] == 'true'
  @products = @products.recently_updated if params[:recently_updated].present? && params[:recently_updated] == 'true'

  # Paginate the filtered list of products
    @products = @products.page(params[:page]).per(20)
  end

  def show
    @product = Product.find(params[:id])
  end
end
