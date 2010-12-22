class BookController < ApplicationController
  def index
  end

  def view
    @isbn = params[:isbn]
    if Bookprice::is_isbn(@isbn)
      @stores = Bookprice::prices(@isbn)
      @not_available = Bookprice::NOT_AVAILABLE
    else
      render :text => '404 Not Found', :status => 404
    end
  end

end
