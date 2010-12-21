class BookController < ApplicationController
  def index
  end

  def view
    if Bookprice.instance.is_isbn(params[:isbn])
      @stores = Bookprice.instance.prices(params[:isbn])
      @not_available = Bookprice::NOT_AVAILABLE
    else
      render :text => '404 Not Found', :status => 404
    end
  end

end
