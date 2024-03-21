class StaticController < ApplicationController
    def about
      @about = About.first
    end
  
    def contact
      @contact = Contact.first
    end
  end