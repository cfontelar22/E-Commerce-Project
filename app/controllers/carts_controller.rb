class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :create, :update, :destroy]

    # GET /cart
    def show
      @cart = Cart.new(session[:cart_items])
    end
    
  
    # POST /cart/items
    def create
      product_id = params[:product_id]
      quantity = params[:quantity].to_i
      product = Product.find_by(id: product_id)
      if product.nil?
        redirect_to products_path, alert: "Product not found."
        return
    end
    @cart = Cart.new(session[:cart_items])
    @cart.add_product(product_id, quantity)
    session[:cart_items] = @cart.items
    redirect_to cart_path, notice: 'Product added to cart.'
  end
  
    # PATCH/PUT /cart/items/:id
    def update
      product_id = params[:id]
      quantity = params[:quantity].to_i
      @cart.update_quantity(product_id, quantity)
      session[:cart] = @cart.items
      redirect_to cart_path
    end
  
    # DELETE /cart/items/:id
    def destroy
      product_id = params[:id]
      @cart.remove_product(product_id)
      session[:cart] = @cart.items
      redirect_to cart_path
    end
  
    private
  
    def set_cart
      session[:cart] ||= []
      @cart = Cart.new(session[:cart])
    end
  end

  